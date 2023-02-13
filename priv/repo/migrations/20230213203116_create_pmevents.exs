defmodule Pmetrics.Repo.Migrations.CreatePmevents do
  use Ecto.Migration

  def change do
    create table(:pm_events, primary_key: false) do
      add(:id, :binary_id, primary_key: true)
      # size: 11 - subject
      add(:subject, :string, null: false)
      add(:evid, :integer, null: false)
      add(:time, :float, null: false)
      add(:dur, :float)
      add(:dose, :float)
      add(:addl, :integer)
      add(:ii, :float)
      add :input, :integer
      add(:out, :float)
      add :outeq, :integer
      add(:c0, :float)
      add(:c1, :float)
      add(:c2, :float)
      add(:c3, :float)
      add :cov, :map

      timestamps()
    end
  end
end
