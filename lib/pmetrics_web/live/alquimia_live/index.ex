defmodule PmetricsWeb.AlquimiaLive.Index do
  use PmetricsWeb, :live_view
  require Logger

  alias Pmetrics.Alquimia
  alias Pmetrics.Alquimia.Schemas.Run

  @topic "Alquimia"

  @impl true
  def mount(_params, _session, socket) do
    PmetricsWeb.Endpoint.subscribe(@topic)
    {:ok, assign(socket, :executions, list_executions())}
  end

  @impl true
  def handle_params(params, _url, socket) do
    {:noreply, apply_action(socket, socket.assigns.live_action, params)}
  end

  @impl true
  def handle_info(%{topic: @topic, event: "new_execution", payload: run}, socket) do
    Logger.info("Alquimia Broadcast received")
    {:noreply, assign(socket, :executions, [run | socket.assigns.executions])}
  end

  def handle_info(%{topic: @topic, event: "update_queue", payload: _}, socket) do
    Logger.info("Alquimia Broadcast received")
    {:noreply, assign(socket, :executions, list_executions())}
  end

  # defp apply_action(socket, :edit, %{"id" => id}) do
  #   socket
  #   |> assign(:page_title, "Edit Admin")
  #   |> assign(:admin, Accounts.get_admin!(id))
  # end

  defp apply_action(socket, :new, _params) do
    socket
    |> assign(:page_title, "New Execution")
    |> assign(:run, %Run{})
  end

  defp apply_action(socket, :index, _params) do
    socket
    |> assign(:page_title, "Listing Executions")
    |> assign(:admin, nil)
  end

  @impl true
  def handle_event("stop", %{"id" => id}, socket) do
    Alquimia.ServerSupervisor.stop_analysis(id)
    {:noreply, assign(socket, :users, list_executions())}
  end

  defp list_executions do
    Alquimia.Schemas.Run.all()
  end
end
