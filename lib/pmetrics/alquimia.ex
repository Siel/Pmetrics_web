defmodule Pmetrics.Alquimia do
  use GenServer
  require Logger

  alias Pmetrics.Alquimia

  @max_concurrent_executions 1
  @ref :alquimia

  # API

  def pid do
    Process.whereis(@ref)
  end

  def start_link(_) do
    GenServer.start_link(__MODULE__, :queue.new)
  end

  def update_queue do
    GenServer.cast(self(), :update_queue)
  end

  def get_queue do
    GenServer.call(pid(), :get_queue)
  end


  # Callbacks

  def init(state) do
    Process.register(self(), @ref)
    {:ok, state}
  end

  def handle_call(:get_queue, _from, queue) do
    {:reply, queue, queue}
  end

  def handle_call({:register_execution, run_params}, _from, queue) do
    with {:ok, run} <-
      Alquimia.Schemas.Run.create_run(run_params),
    {:ok, _pid} <-
      Alquimia.ServerSupervisor.start_analysis(
        run.id,
        run.model_txt,
        run.data_txt
      ) do
        queue = :queue.in(run, queue)
        queue = queue |> update_queue_()

        #iniciar una nueva ejecución si es el caso
        {:reply, {:ok, run}, queue}
      end
  end

  def handle_info(:update_queue, queue) do
    Logger.info("update queue")
    {:noreply, update_queue_(queue)}
  end

  # Util

  defp update_queue_(queue) do
    if Alquimia.ServerSupervisor.active_analysis() < @max_concurrent_executions do
      case :queue.out(queue) do
        {:empty, q} -> q
        {{:value, run}, q} ->
          Alquimia.Server.execute(run.id)
          q
      end
    else
      queue
    end
  end



end
