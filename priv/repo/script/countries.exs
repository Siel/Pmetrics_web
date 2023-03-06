# mix run priv/repo/script/countries.exs

defmodule Util do
  def insert(list) do
    [code | [ name]] = list

    {:ok, _} =
      Pmetrics.Repo.insert(
        Pmetrics.Dataset.Countries.changeset( %Pmetrics.Dataset.Countries{}, %{
          code: code,
          name: name
      }))
    end
  end

    "countries.csv"
    |> Path.expand(__DIR__)
    |> File.read!()
    |> String.split("\r\n", trim: true)
    |> Enum.drop(1)
    |> Enum.map(fn str -> String.split(str, ",") end)
    #|> Enum.map(fn x -> length(x) end)
    #|> Enum.filter(fn x -> x != 25 end)
    |> Enum.map(fn val -> Util.insert(val) end)
    |> IO.inspect()
