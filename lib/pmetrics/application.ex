defmodule Pmetrics.Application do
  # See https://hexdocs.pm/elixir/Application.html
  # for more information on OTP Applications
  @moduledoc false

  use Application

  @impl true
  def start(_type, _args) do
    children = [
      # Start the Telemetry supervisor
      PmetricsWeb.Telemetry,
      # Start the Ecto repository
      Pmetrics.Repo,
      # Start the PubSub system
      {Phoenix.PubSub, name: Pmetrics.PubSub},
      # Start Finch
      {Finch, name: Pmetrics.Finch},
      # Start the Endpoint (http/https)
      PmetricsWeb.Endpoint,
      {Registry, keys: :unique, name: Pmetrics.Alquimia.ServerRegistry},
      Pmetrics.Alquimia.ServerSupervisor
      # Start a worker by calling: Pmetrics.Worker.start_link(arg)
      # {Pmetrics.Worker, arg}
    ]

    # See https://hexdocs.pm/elixir/Supervisor.html
    # for other strategies and supported options
    opts = [strategy: :one_for_one, name: Pmetrics.Supervisor]
    Supervisor.start_link(children, opts)
  end

  # Tell Phoenix to update the endpoint configuration
  # whenever the application is updated.
  @impl true
  def config_change(changed, _new, removed) do
    PmetricsWeb.Endpoint.config_change(changed, removed)
    :ok
  end
end
