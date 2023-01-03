defmodule Pmetrics.Alquimia.Analysis do
  require Logger

  @derive {Jason.Encoder, only: [:result, :id, :status]}
  defstruct model: nil,
            data: nil,
            model_txt: "",
            result: nil,
            conn: nil,
            path: "",
            out_path: nil,
            mode: :automatic,
            id: "",
            status: nil

  # @pkpdb_url "http://localhost:4000/api/v0/"

  alias __MODULE__

  @doc """
  harcoded execution
  """
  # def new(data_id) do
  #   with model <- Alquimia.Model.new([{"Ka", "0", "5"}, {"V", "0", "10"}]),
  #        {:ok, data} <- fetch_data(data_id),
  #        conn <- Rservex.open(),
  #        {:ok, path} <- get_path(conn) do
  #     {:ok, _} = load_pmetrics(conn)
  #     %Analysis{model: model, data: data |> IO.inspect(), path: path, conn: conn}
  #   else
  #     error ->
  #       error
  #   end
  # end

  def new(model_txt, data_txt, id \\ "") do
    with conn <- Rservex.open(),
         {:ok, path} <- get_path(conn) do
      load_pmetrics(conn)

      %Analysis{
        model_txt: model_txt,
        data: data_txt,
        path: path,
        conn: conn,
        mode: :manual,
        id: id,
        status: :created
      }
    else
      error ->
        raise(error)
    end
  end

  # defp fetch_data(data_id) do
  #   case HTTPoison.get!(@pkpdb_url <> "datasets/" <> data_id <> "/csv", [
  #          {"api_key", "90HTp700+8Wx4pBzHy3/ibmtOFQjRBjyCinRXj1jgItTmvC5XMw2iD4Hgm09Ci32"}
  #        ]) do
  #     %{status_code: 200, body: body} ->
  #       {
  #         :ok,
  #         body
  #         |> Jason.decode!()
  #         |> Map.get("content")
  #       }

  #     _ ->
  #       {:error, :fetch_data_error}
  #   end
  # end

  # def explore_models(analysis = %Analysis{mode: :automatic}) do
  #   [
  #     analysis |> update_model([{"V", "0", "100"}, {"Ke", "0", "5"}]),
  #     analysis |> update_model([{"Ka", "0", "3"}, {"V", "0", "100"}, {"Ke", "0", "5"}]),
  #     analysis
  #     |> update_model([
  #       {"V", "0", "150"},
  #       {"Ke", "0", "5"},
  #       {"Kcp", "0", "5"},
  #       {"Kpc", "0", "5"}
  #     ]),
  #     analysis
  #     |> update_model([
  #       {"Ka", "0", "0.2"},
  #       {"V", "0", "150"},
  #       {"Ke", "0", "5"},
  #       {"Kcp", "0", "5"},
  #       {"Kpc", "0", "5"}
  #     ])
  #   ]
  #   |> execute()
  # end

  # def update_model(analysis = %Analysis{mode: :automatic}, model) do
  #   %{analysis | model: Alquimia.Model.new(model)}
  # end

  # def execute(analysis_list) when is_list(analysis_list) do
  #   analysis_list
  #   |> Enum.map(&execute/1)
  # end

  # def execute(analysis = %Analysis{mode: :automatic}) do
  #   Rservex.eval(analysis.conn, "setwd('" <> analysis.path <> "')")
  #   Alquimia.Model.create_file(analysis.model, analysis.path)

  #   File.write!(analysis.path <> "/data.csv", analysis.data)
  #   # hacky
  #   {:ok, {:xt_arr_str, out_path}} = Rservex.eval(analysis.conn, "NPrun(intern = T)")
  #   # Rservex.close(analysis.conn)
  #   %{analysis | status: :running, out_path: out_path}
  # end

  def execute(analysis = %Analysis{mode: :manual}) do
    Rservex.eval(analysis.conn, "setwd('" <> analysis.path <> "')")
    # Alquimia.Model.create_file(analysis.model, analysis.path)

    File.write!(analysis.path <> "/data.csv", analysis.data)
    File.write!(analysis.path <> "/model.txt", analysis.model_txt)
    # hacky
    {:ok, {:xt_arr_str, out_path}} = Rservex.eval(analysis.conn, "NPrun(alq = T)")
    %{analysis | status: :running, out_path: out_path}
  end

  def parse_out_data(analysis = %Analysis{}) do
    create_out_file(analysis)
    Logger.info("Parsing data...")

    data =
      case File.read!(analysis.out_path <> "/alquimiaData.json")
           |> String.trim_trailing()
           |> Jason.decode() do
        {:ok, [data]} ->
          IO.inspect(data)
          data

        {:error, error} ->
          IO.inspect(error)
          IO.inspect(File.read!(analysis.out_path <> "/alquimiaData.json"))
          :timer.sleep(1000)
          parse_out_data(analysis)
      end

    %{analysis | result: data}
  end

  def get_outdata(analysis = %Analysis{}) do
    (analysis.out_path <> "/NPAGout.Rdata")
    |> File.read!()
    |> Base.encode64()
  end

  defp get_path(conn) do
    case Rservex.eval(conn, "getwd()") do
      {:ok, {:xt_arr_str, path}} ->
        {:ok, path}

      error ->
        error
    end
  end

  defp create_out_file(analysis = %Analysis{}) do
    Logger.info("Creating OUT data")
    # Executing w/out the second patameter means that is going to generate the out file por NPAG
    Rservex.eval(analysis.conn, "Pmetrics:::makeRdata('" <> analysis.out_path <> "', remote = T, reportType=1)")
    Rservex.close(analysis.conn)
  end

  defp load_pmetrics(conn) do
    # try do
    #   Rservex.eval(conn, "detach(package:Pmetrics)")
    # rescue
    #   error ->
    #     IO.inspect(error)
    #     IO.inspect("already detached")
    # end

    Rservex.eval(conn, "library(Pmetrics)")
  end
end

# import Alquimia.Analysis
# an |> update_model([{"Ke", "0", "2"}, {"V", "0", "200"}, {"Ka", "0", "0.2"}]) |> execute()
