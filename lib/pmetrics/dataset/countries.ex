defmodule Pmetrics.Dataset.Countries do
  @moduledoc false
  use Ecto.Schema
  import Ecto.Changeset

  @foreign_key_type :integer
  @primary_key {:id, :binary_id, autogenerate: true}
  schema "countries" do
    field :code, :string
    field :name, :string


    timestamps()
  end

  @doc false
  def changeset(countries, attrs) do
    countries
    |> cast(attrs, [
      :id,
      :code,
      :name
    ])
    |> validate_required([:code, :name])
  end
end
