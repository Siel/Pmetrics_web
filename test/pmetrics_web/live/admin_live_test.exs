defmodule PmetricsWeb.AlquimiaLiveTest do
  use PmetricsWeb.ConnCase

  import Phoenix.LiveViewTest
  import Pmetrics.AccountsFixtures

  @create_attrs %{email: "some email"}
  @update_attrs %{email: "some updated email"}
  @invalid_attrs %{email: nil}

  defp create_admin(_) do
    admin = admin_fixture()
    %{admin: admin}
  end

  describe "Index" do
    setup [:create_admin]

    test "lists all users", %{conn: conn, admin: admin} do
      {:ok, _index_live, html} = live(conn, ~p"/users")

      assert html =~ "Listing Users"
      assert html =~ admin.email
    end

    test "saves new admin", %{conn: conn} do
      {:ok, index_live, _html} = live(conn, ~p"/users")

      assert index_live |> element("a", "New Admin") |> render_click() =~
               "New Admin"

      assert_patch(index_live, ~p"/users/new")

      assert index_live
             |> form("#admin-form", admin: @invalid_attrs)
             |> render_change() =~ "can&#39;t be blank"

      {:ok, _, html} =
        index_live
        |> form("#admin-form", admin: @create_attrs)
        |> render_submit()
        |> follow_redirect(conn, ~p"/users")

      assert html =~ "Admin created successfully"
      assert html =~ "some email"
    end

    test "updates admin in listing", %{conn: conn, admin: admin} do
      {:ok, index_live, _html} = live(conn, ~p"/users")

      assert index_live |> element("#users-#{admin.id} a", "Edit") |> render_click() =~
               "Edit Admin"

      assert_patch(index_live, ~p"/users/#{admin}/edit")

      assert index_live
             |> form("#admin-form", admin: @invalid_attrs)
             |> render_change() =~ "can&#39;t be blank"

      {:ok, _, html} =
        index_live
        |> form("#admin-form", admin: @update_attrs)
        |> render_submit()
        |> follow_redirect(conn, ~p"/users")

      assert html =~ "Admin updated successfully"
      assert html =~ "some updated email"
    end

    test "deletes admin in listing", %{conn: conn, admin: admin} do
      {:ok, index_live, _html} = live(conn, ~p"/users")

      assert index_live |> element("#users-#{admin.id} a", "Delete") |> render_click()
      refute has_element?(index_live, "#admin-#{admin.id}")
    end
  end

  describe "Show" do
    setup [:create_admin]

    test "displays admin", %{conn: conn, admin: admin} do
      {:ok, _show_live, html} = live(conn, ~p"/users/#{admin}")

      assert html =~ "Show Admin"
      assert html =~ admin.email
    end

    test "updates admin within modal", %{conn: conn, admin: admin} do
      {:ok, show_live, _html} = live(conn, ~p"/users/#{admin}")

      assert show_live |> element("a", "Edit") |> render_click() =~
               "Edit Admin"

      assert_patch(show_live, ~p"/users/#{admin}/show/edit")

      assert show_live
             |> form("#admin-form", admin: @invalid_attrs)
             |> render_change() =~ "can&#39;t be blank"

      {:ok, _, html} =
        show_live
        |> form("#admin-form", admin: @update_attrs)
        |> render_submit()
        |> follow_redirect(conn, ~p"/users/#{admin}")

      assert html =~ "Admin updated successfully"
      assert html =~ "some updated email"
    end
  end
end
