defmodule Pmetrics.Dataset.Cities do
  @moduledoc false
  use Ecto.Schema
  import Ecto.Changeset


  @foreign_key_type :integer
  @primary_key {:id, :binary_id, autogenerate: true}
  schema "cities" do
    field :country_id, :binary_id
    field :name, :string

    timestamps()
  end

  @doc false
  def changeset(cities, attrs) do
    cities
    |> cast(attrs, [
      :country_id,
      :name
    ])
    |> validate_required([:country_id, :name])
  end
end
