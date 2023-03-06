defmodule Pmetrics.Repo.Migrations.CreateCitiesTable do
  use Ecto.Migration

  def change do
    create table(:cities, primary_key: false) do
      add :id, :binary_id, primary_key: true
      add :country_id, references(:countries, type: :binary_id, on_delete: :nilify_all), null: false
      add :name, :string

      timestamps()
    end
  end
end
