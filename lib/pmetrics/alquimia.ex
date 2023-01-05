defmodule Pmetrics.Alquimia do
  use GenServer
  require Logger

  alias Pmetrics.Alquimia

  @max_concurrent_executions 3
  @ref :alquimia
  @topic "Alquimia"
  @poll_queue_rate 5_000

  # API

  def pid do
    Process.whereis(@ref)
  end

  def start_link(_) do
    GenServer.start_link(__MODULE__, [])
  end

  def poll_queue do
    # if queued_analysis() |> Enum.count() > 0 do
    Process.send_after(pid(), :poll_queue, @poll_queue_rate)
    # end
  end

  def get_queue do
    GenServer.call(pid(), :get_queue)
  end

  # Callbacks

  def init(state) do
    Process.register(self(), @ref)
    # PmetricsWeb.Endpoint.subscribe(@topic)
    poll_queue()
    {:ok, state}
  end

  def handle_call(:get_queue, _from, queue) do
    {:reply, queue, queue}
  end

  def handle_call({:register_execution, run_params}, _from, _queue) do
    with {:ok, run} <-
           Alquimia.Schemas.Run.create_run(run_params),
         {:ok, _pid} <-
           Alquimia.ServerSupervisor.create_analysis(
             run.id,
             run.model_txt,
             run.data_txt
           ) do
      PmetricsWeb.Endpoint.broadcast_from(self(), @topic, "new_execution", run)
      {:reply, {:ok, run}, queued_analysis() |> execute()}
    end
  end

  def handle_info(:execute_queue, _queue) do
    Logger.info("Fetching queue")
    {:noreply, queued_analysis() |> execute()}
  end

  def handle_info(:poll_queue, _queue) do
    # Logger.info("Polling queue")
    poll_queue()
    {:noreply, queued_analysis() |> execute()}
  end

  def handle_call({:execute_queue_after, delay}, queue) do
    Process.send_after(Alquimia.pid(), :execute_queue, delay)
    {:reply, :ok, queue}
  end

  # Util

  defp execute(queue) do
    if n_active_analysis() < @max_concurrent_executions do
      case queue do
        [run | q] ->
          Alquimia.Server.execute(run.id)
          execute(q)

        [] ->
          []
      end
    else
      queue
    end
  end

  def active_analysis do
    Alquimia.ServerSupervisor.analysis()
    |> Enum.filter(fn analysis -> analysis.status == "running" end)
  end

  def queued_analysis do
    Alquimia.ServerSupervisor.analysis()
    |> Enum.filter(fn analysis -> analysis.status == :created end)
    |> Enum.sort(&(DateTime.compare(&1.created_at, &2.created_at) == :lt))
  end

  def n_active_analysis do
    active_analysis()
    |> Enum.reduce(0, fn ele, acc -> if ele, do: acc + 1, else: acc end)
  end
end
