defmodule Pmetrics.AccountsTest do
  use Pmetrics.DataCase

  alias Pmetrics.Accounts

  describe "users" do
    alias Pmetrics.Accounts.Admin

    import Pmetrics.AccountsFixtures

    @invalid_attrs %{email: nil}

    test "list_users/0 returns all users" do
      admin = admin_fixture()
      assert Accounts.list_users() == [admin]
    end

    test "get_admin!/1 returns the admin with given id" do
      admin = admin_fixture()
      assert Accounts.get_admin!(admin.id) == admin
    end

    test "create_admin/1 with valid data creates a admin" do
      valid_attrs = %{email: "some email"}

      assert {:ok, %Admin{} = admin} = Accounts.create_admin(valid_attrs)
      assert admin.email == "some email"
    end

    test "create_admin/1 with invalid data returns error changeset" do
      assert {:error, %Ecto.Changeset{}} = Accounts.create_admin(@invalid_attrs)
    end

    test "update_admin/2 with valid data updates the admin" do
      admin = admin_fixture()
      update_attrs = %{email: "some updated email"}

      assert {:ok, %Admin{} = admin} = Accounts.update_admin(admin, update_attrs)
      assert admin.email == "some updated email"
    end

    test "update_admin/2 with invalid data returns error changeset" do
      admin = admin_fixture()
      assert {:error, %Ecto.Changeset{}} = Accounts.update_admin(admin, @invalid_attrs)
      assert admin == Accounts.get_admin!(admin.id)
    end

    test "delete_admin/1 deletes the admin" do
      admin = admin_fixture()
      assert {:ok, %Admin{}} = Accounts.delete_admin(admin)
      assert_raise Ecto.NoResultsError, fn -> Accounts.get_admin!(admin.id) end
    end

    test "change_admin/1 returns a admin changeset" do
      admin = admin_fixture()
      assert %Ecto.Changeset{} = Accounts.change_admin(admin)
    end
  end
end
