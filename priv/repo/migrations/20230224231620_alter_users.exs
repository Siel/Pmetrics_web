defmodule Pmetrics.Repo.Migrations.AlterUsers do
  use Ecto.Migration

  def change do
    alter table(:users) do
      add :country_id, references(:countries, type: :binary_id, on_delete: :delete_all), null: false
      add :city_id, references(:cities, type: :binary_id, on_delete: :delete_all)
      add :university_id, references(:university, type: :binary_id, on_delete: :delete_all)
      add :other_university, :string
    end
  end
end
