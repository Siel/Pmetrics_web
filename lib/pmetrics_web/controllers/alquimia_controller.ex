defmodule PmetricsWeb.AlquimiaController do
  use PmetricsWeb, :controller

  alias Pmetrics.Alquimia

  #TODO: This needs to be rewritten, it is just a proof of concept
  #In general data is not provided by the user but selected by them.
  #Data will be stored on the bank submodule. All this function will
  #need are the data's id and some identifier for the model

  def new(conn, %{"run" => run_params}) do
    with {:ok, run} <-
           Alquimia.Schemas.Run.create_run(run_params),
         {:ok, _} <-
           Alquimia.ServerSupervisor.start_analysis(
             run.id,
             run.model_txt,
             run.data_txt
           ),
         _ <- Alquimia.Server.execute(run.id) do
      conn
      |> render("run.json", run: run)
    end
  end
end
