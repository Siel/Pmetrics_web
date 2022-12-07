defmodule Pmetrics.Repo do
  use Ecto.Repo,
    otp_app: :pmetrics,
    adapter: Ecto.Adapters.Postgres
end
