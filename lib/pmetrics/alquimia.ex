defmodule Pmetrics.Alquimia do
  use GenServer
  require Logger

  alias Pmetrics.Alquimia

  @max_concurrent_executions 1
  @polling_rate

  # API

  def start_link(_) do
    GenServer.start_link(__MODULE__, :queue.new)
  end

  def register_execution(run_params) do
    GenServer.call(self, {:register_execution, run_params})
  end


  # Callbacks

  def init(state) do
    {:ok, state}
  end

  def handle_call({:register_execution, run_params}, _from, queue) do
    with {:ok, run} <-
      Alquimia.Schemas.Run.create_run(run_params),
    {:ok, analysis} <-
      Alquimia.ServerSupervisor.start_analysis(
        run.id,
        run.model_txt,
        run.data_txt
      ) do
        queue = :queue.in(analysis, queue)
                |> check_for_executions()

        #iniciar una nueva ejecución si es el caso
        {:ok, queue, queue}
      end
  end

  def check_for_executions(queue) do
    if Alquimia.ServerSupervisor.active_analysis |> Enum.count < @max_concurrent_executions do
      case :queue.out(queue) do
        {:empty, q} -> q
        {{:value, analysis}, q} ->
          Alquimia.Server.execute(analysis.id)
          q
      end
    end
  end

end
