defmodule Pmetrics.Alquimia.ServerSupervisor do
  use DynamicSupervisor
  alias Pmetrics.Alquimia

  # API
  def start_link(_args) do
    DynamicSupervisor.start_link(__MODULE__, :ok, name: __MODULE__)
  end

  def start_analysis(id, model_txt, data_txt) do
    child_spec = %{
      id: Alquimia.Server,
      start: {Alquimia.Server, :start_link, [id, model_txt, data_txt]},
      restart: :transient
      # only restart processes that terminated abnormaly, timeout processes will
      # not be restarted
    }

    # This will return {:error, :con_refused} when Rserve is not in execution
    DynamicSupervisor.start_child(__MODULE__, child_spec)
  end

  def stop_analysis(id) do
    child_pid = Alquimia.Server.analysis_pid(id)
    DynamicSupervisor.terminate_child(__MODULE__, child_pid)
  end

  def analysis do
    DynamicSupervisor.which_children(__MODULE__)
    |> Enum.map(fn {_, analysis_pid, _, _} ->
      Registry.keys(Alquimia.ServerRegistry, analysis_pid) |> List.first()
    end)
    |> Enum.map(&Alquimia.Server.summary/1)
  end

  def active_analysis do
    Alquimia.ServerSupervisor.analysis
    |> Enum.filter(fn analysis -> analysis.status == "running" end)
    |> Enum.reduce(0, fn ele, acc -> if ele, do: acc+1, else: acc  end)
  end

  # Server Callbacks
  def init(:ok) do
    DynamicSupervisor.init(strategy: :one_for_one)
  end
end
