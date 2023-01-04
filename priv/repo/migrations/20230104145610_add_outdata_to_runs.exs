defmodule Pmetrics.Repo.Migrations.AddOutdataToRuns do
  use Ecto.Migration

  def change do
    alter table(:runs) do
      add :out_data, :text
    end
  end
end
