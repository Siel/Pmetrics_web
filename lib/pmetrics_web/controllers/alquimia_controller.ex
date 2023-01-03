defmodule PmetricsWeb.AlquimiaController do
  use PmetricsWeb, :controller

  alias Pmetrics.Alquimia

  #TODO: This needs to be rewritten, it is just a proof of concept
  #In general data is not provided by the user but selected by them.
  #Data will be stored on the bank submodule. All this function will
  #need are the data's id and some identifier for the model

  def new(conn, %{"run" => run_params}) do
    with {:ok, run} <- Alquimia.register_execution(run_params) do
      conn
      |> render("run.json", run: run)
    end
  end

  def get_status(conn, %{"id" => id}) do
    status = Alquimia.Server.summary(id)
    render(conn, "status.json", status: status)
  end

  def get_outdata(conn, %{"id" => id}) do
    outdata_txt = Alquimia.Server.get_outdata(id)
    render(conn, "outdata.json", outdata_txt: outdata_txt)
  end
end
