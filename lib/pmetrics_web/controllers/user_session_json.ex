defmodule PmetricsWeb.UserSessionJSON do
  alias Pmetrics.Session.User

  @doc """
  Renders a ok message
  """
  def ok(params) do
    %{ok: "ok"}
  end

  @doc """
  Renders a token in the case of a successful login
  """
  def token(%{token: token}) do
    %{data: %{token: Base.url_encode64(token, padding: false)}}
  end

  @doc """
  Renders an error
  """
  def error(%{message: message}) do
    %{error: %{message: message}}
  end
end
