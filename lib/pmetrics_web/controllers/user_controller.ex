defmodule PmetricsWeb.UserController do
  use PmetricsWeb, :controller

  alias Pmetrics.Session
  # alias Pmetrics.Session.User

  action_fallback PmetricsWeb.FallbackController

  # TODO: move this function out of this context
  def index(conn, _params) do
    users = Session.list_users()
    render(conn, :index, users: users)
  end

  # def create(conn, %{"user" => user_params}) do
  #   with {:ok, %User{} = user} <- Session.create_user(user_params) do
  #     conn
  #     |> put_status(:created)
  #     |> put_resp_header("location", ~p"/api/users/#{user}")
  #     |> render(:show, user: user)
  #   end
  # end

  # def show(conn, %{"id" => id}) do
  #   user = Session.get_user!(id)
  #   render(conn, :show, user: user)
  # end

  # def update(conn, %{"id" => id, "user" => user_params}) do
  #   user = Session.get_user!(id)

  #   with {:ok, %User{} = user} <- Session.update_user(user, user_params) do
  #     render(conn, :show, user: user)
  #   end
  # end

  # def delete(conn, %{"id" => id}) do
  #   user = Session.get_user!(id)

  #   with {:ok, %User{}} <- Session.delete_user(user) do
  #     send_resp(conn, :no_content, "")
  #   end
  # end
end
