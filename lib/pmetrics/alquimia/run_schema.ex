defmodule Pmetrics.Alquimia.Schemas.Run do
  use Ecto.Schema
  import Ecto.Changeset

  @derive {Jason.Encoder, only: [:id, :name, :description, :status, :started_at, :finished_at]}
  @primary_key {:id, :binary_id, autogenerate: true}
  schema "runs" do
    field :data_txt, :string
    field :description, :string
    field :error_code, :string
    field :finished_at, :utc_datetime
    field :model_txt, :string
    field :name, :string
    field :out_path, :string
    field :started_at, :utc_datetime
    field :status, :string
    field :out_data, :string

    timestamps()
  end

  @doc false
  def changeset(run, attrs) do
    run
    |> cast(attrs, [
      :status,
      :error_code,
      :out_path,
      :name,
      :description,
      :model_txt,
      :data_txt,
      :started_at,
      :finished_at,
      :out_data
    ])
    |> validate_required([:status, :model_txt, :data_txt])
  end

  import Ecto.Query, warn: false
  alias Pmetrics.Repo
  alias Pmetrics.Alquimia.Schemas.Run

  def change_run(%Run{} = run, attrs \\ %{}) do
    Run.changeset(run, attrs)
  end

  def create_run(attrs \\ %{}) do
    %Run{}
    |> Run.changeset(attrs |> Map.put_new("status", "created"))
    |> Repo.insert()
  end

  def get_run!(id) do
    Repo.get!(Run, id)
  end

  def all do
    from(
      r in Run,
      order_by: [desc: r.inserted_at]
    )
    |> Repo.all()
  end

  def paginate(query, page, size) do
    from query,
      limit: ^size,
      offset: ^((page - 1) * size)
  end

  def get_out_data!(id) do
    get_run!(id)
    |> Map.get(:out_data)
  end

  def update_execution(analysis) do
    Repo.get!(Run, analysis.id)
    |> Run.changeset(data_to_update(analysis))
    |> Repo.update()
  end

  defp data_to_update(analysis = %{status: "running"}) do
    %{
      status: analysis.status,
      started_at: DateTime.utc_now(),
      out_path: analysis.out_path
    }
  end

  defp data_to_update(analysis = %{status: "finished"}) do
    %{
      status: analysis.status,
      finished_at: DateTime.utc_now(),
      out_data: analysis.out_data
    }
  end
end
