defmodule Pmetrics.AccountsFixtures do
  @moduledoc """
  This module defines test helpers for creating
  entities via the `Pmetrics.Accounts` context.
  """

  @doc """
  Generate a admin.
  """
  def admin_fixture(attrs \\ %{}) do
    {:ok, admin} =
      attrs
      |> Enum.into(%{
        email: "some email"
      })
      |> Pmetrics.Accounts.create_admin()

    admin
  end
end
