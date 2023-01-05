defmodule Pmetrics.Alquimia.Server do
  use GenServer
  require Logger
  alias Pmetrics.Alquimia
  alias Alquimia.Analysis
  alias Alquimia.Schemas.Run

  @timeout :timer.hours(1)
  @polling_rate 3000
  @topic "Alquimia"

  # Server API

  def start_link(id, model_txt, data_txt) do
    GenServer.start_link(
      __MODULE__,
      {id, model_txt, data_txt},
      name: via_tuple(id)
    )
  end

  def summary(id) do
    GenServer.call(via_tuple(id), :summary)
  end

  def execute(id) do
    GenServer.cast(via_tuple(id), :execute)
  end

  # Server Callbacks
  def init({id, model_txt, data_txt}) do
    Logger.info("Spawned a process with id: #{id}")
    Process.flag(:trap_exit, true)
    {:ok, Analysis.new(model_txt, data_txt, id), @timeout}
  end

  def handle_call(:summary, _from, analysis) do
    {:reply, analysis, analysis, @timeout}
  end

  def handle_cast(:execute, analysis) do
    Logger.info("__________EXECUTE__________")

    analysis =
      analysis
      |> Alquimia.Analysis.execute()
      |> Map.put(:status, "running")

    Run.update_execution(analysis)
    PmetricsWeb.Endpoint.broadcast_from(self(), @topic, "update_queue", [])

    schedule_poll()
    {:noreply, analysis, @timeout}
  end

  def handle_info(:poll, analysis) do
    Logger.info("polling: " <> analysis.out_path)

    cond do
      File.exists?(analysis.out_path <> "/alquimiaData.json") ->
        Logger.info("Execution " <> analysis.id <> " ended")

        analysis =
          analysis
          |> Alquimia.Analysis.parse_out_data()
          |> Map.put(:status, "finished")
          |> Map.put(:out_data, Alquimia.Analysis.get_outdata(analysis))

        Run.update_execution(analysis)
        PmetricsWeb.Endpoint.broadcast_from(self(), @topic, "update_queue", [])

        # :ok = GenServer.call(Alquimia.pid(), {:execute_queue_after, 300})
        # Process.send_after(Alquimia.pid(), :execute_queue, 300)
        {:stop, {:shutdown, :execution_finished}, analysis}

      true ->
        schedule_poll()
        {:noreply, analysis}
    end
  end

  def handle_info(:timeout, analysis) do
    # cambiar cast to call en las ejecuciones, verificar el timeout
    # si llega un timeout cambiar el estado, actualizar la db y apagar el proceso
    # analysis =
    #   analysis
    #   |> Alquimia.Analysis.parse_out_data()
    #   |> Map.put(:status, "timeout")
    # Run.update_execution(analysis)
    {:stop, {:shutdown, :timeout}, analysis}
  end

  # util

  def terminate(_reason, _state) do
    # Process.send_after(Alquimia.pid(), :execute_queue, 0)
    :ok
  end

  def schedule_poll() do
    Process.send_after(self(), :poll, @polling_rate)
  end

  def via_tuple(id) do
    {:via, Registry, {Alquimia.ServerRegistry, id}}
  end

  def analysis_pid(id) do
    id
    |> via_tuple()
    |> GenServer.whereis()
  end
end
