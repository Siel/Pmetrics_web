defmodule Pmetrics.Dataset.University do
  @moduledoc false
  use Ecto.Schema
  import Ecto.Changeset


  @foreign_key_type :integer
  @primary_key {:id, :binary_id, autogenerate: true}
  schema "university" do
    field :country_id, :binary_id
    field :name, :string
    field :geo_point, :string

    timestamps()
  end

  @doc false
  def changeset(university, attrs) do
    university
    |> cast(attrs, [
      :country_id,
      :name,
      :geo_point
    ])
    |> validate_required([:country_id, :name])
  end
end
