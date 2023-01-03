defmodule PmetricsWeb.AdminLive.Index do
  use PmetricsWeb, :live_view

  alias Pmetrics.Accounts
  alias Pmetrics.Accounts.Admin

  @impl true
  def mount(_params, _session, socket) do
    {:ok, assign(socket, :users, list_users())}
  end

  @impl true
  def handle_params(params, _url, socket) do
    {:noreply, apply_action(socket, socket.assigns.live_action, params)}
  end

  defp apply_action(socket, :edit, %{"id" => id}) do
    socket
    |> assign(:page_title, "Edit Admin")
    |> assign(:admin, Accounts.get_admin!(id))
  end

  defp apply_action(socket, :new, _params) do
    socket
    |> assign(:page_title, "New Admin")
    |> assign(:admin, %Admin{})
  end

  defp apply_action(socket, :index, _params) do
    socket
    |> assign(:page_title, "Listing Users")
    |> assign(:admin, nil)
  end

  @impl true
  def handle_event("delete", %{"id" => id}, socket) do
    admin = Accounts.get_admin!(id)
    {:ok, _} = Accounts.delete_admin(admin)

    {:noreply, assign(socket, :users, list_users())}
  end

  defp list_users do
    Accounts.list_users()
  end
end
