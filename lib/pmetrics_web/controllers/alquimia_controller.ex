defmodule PmetricsWeb.AlquimiaController do
  use PmetricsWeb, :controller

  alias Pmetrics.Alquimia

  # action_fallback PmetricsWeb.FallbackController

  #TODO: This needs to be rewritten, it is just a proof of concept
  #In general data is not provided by the user but selected by them.
  #Data will be stored on the bank submodule. All this function will
  #need are the data's id and some identifier for the model

  def new(conn, %{"run" => run_params}) do
    with {:ok, run} <- register_execution(run_params) do
      conn
      |> render("run.json", run: run)
    end
  end

  def get_status(conn, %{"id" => id}) do

    status = Alquimia.Schemas.Run.get_run!(id)
    render(conn, "status.json", status: status)
  end

  def get_outdata(conn, %{"id" => id}) do
    outdata_txt = Alquimia.Schemas.Run.get_out_data!(id)
    render(conn, "outdata.json", outdata_txt: outdata_txt)
  end

  defp register_execution(run_params) do
    GenServer.call(Alquimia.pid, {:register_execution, run_params})
  end
end
