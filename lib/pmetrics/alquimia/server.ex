defmodule Pmetrics.Alquimia.Server do
  use GenServer
  require Logger
  alias Pmetrics.Alquimia
  alias Alquimia.Analysis
  alias Alquimia.Schemas.Run

  @timeout :timer.hours(1)
  @polling_rate 1000

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

  def get_outdata(id) do
    GenServer.call(via_tuple(id), :outdata)
  end

  def execute(id) do
    # GenServer.call(via_tuple(id), :execute)
    GenServer.cast(via_tuple(id), :execute)
  end

  # Server Callbacks
  def init({id, model_txt, data_txt}) do
    Logger.info("Spawned a process with id: #{id}")
    {:ok, Analysis.new(model_txt, data_txt, id), @timeout}
  end

  def handle_call(:summary, _from, analysis) do
    {:reply, analysis, analysis, @timeout}
  end

  def handle_call(:outdata, _from, analysis) do
    outdata_txt = Alquimia.Analysis.get_outdata(analysis)
    {:reply, outdata_txt, analysis, @timeout}
  end

  def handle_cast(:execute, analysis) do
    Logger.info("__________EXECUTE__________")

    analysis =
      analysis
      |> Alquimia.Analysis.execute()
      |> Map.put(:status, "running")

    IO.inspect(analysis)

    Run.update_execution(analysis)

    schedule_poll()
    {:noreply, analysis, @timeout}
  end

  def handle_info(:poll, analysis) do
    Logger.info("polling: " <> analysis.out_path)

    cond do
      File.exists?(analysis.out_path <> "/alquimiaData.json") ->
        Logger.info("Execution " <> analysis.id <> " ended")

        # TODO: Should I start another process to parse the data?
        analysis =
          analysis
          |> Alquimia.Analysis.parse_out_data()
          |> Map.put(:status, "finished")

        # TODO: is it ok to call the DB from here?
        Run.update_execution(analysis)

        {:noreply, analysis}

      true ->
        schedule_poll()
        {:noreply, analysis}
    end
  end

  def handle_info(:timeout, analysis) do
    {:stop, {:shutdown, :timeout}, analysis}
  end

  # util

  def terminate(_reason, _game) do
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
