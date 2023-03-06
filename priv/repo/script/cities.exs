# mix run priv/repo/script/cities.exs

defmodule Util do
  def insert(list) do
    [country_id | [ name]] = list

    {:ok, _} =
      Pmetrics.Repo.insert(
        Pmetrics.Dataset.Cities.changeset( %Pmetrics.Dataset.Cities{}, %{
          country_id: country_id,
          name: name
      }))
    end
  end

    "cities.csv"
    |> Path.expand(__DIR__)
    |> File.read!()
    |> String.split("\r\n", trim: true)
    |> Enum.drop(1)
    |> Enum.map(fn str -> String.split(str, ",") end)
    #|> Enum.map(fn x -> length(x) end)
    #|> Enum.filter(fn x -> x != 25 end)
    |> Enum.map(fn val -> Util.insert(val) end)
    |> IO.inspect()
