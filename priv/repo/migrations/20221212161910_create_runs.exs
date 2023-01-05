defmodule Pmetrics.Repo.Migrations.CreateRuns do
  use Ecto.Migration

  # TODO: add user

  def change do
    create table(:runs, primary_key: false) do
      add :id, :binary_id, primary_key: true
      add :status, :string
      add :error_code, :string
      add :out_path, :string
      add :name, :string
      add :description, :text
      add :model_txt, :text
      add :data_txt, :text
      add :started_at, :utc_datetime
      add :finished_at, :utc_datetime

      timestamps()
    end
  end
end
