defmodule Pmetrics.Repo.Migrations.CreateUniversityTable do
  use Ecto.Migration

  def change do
    create table(:university, primary_key: false) do
      add :id, :binary_id, primary_key: true
      add :country_id, references(:countries, type: :binary_id, on_delete: :nilify_all)
      add :name, :string
      add :geo_point, :string

      timestamps()
    end
  end
end
