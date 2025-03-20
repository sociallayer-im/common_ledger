defmodule CommonLedgerWeb.GroupController do
  use CommonLedgerWeb, :controller

  alias CommonLedger.Groups
  alias CommonLedger.Groups.Group
  alias CommonLedger.Repo
  alias CommonLedger.Teams

  def index(conn, _params) do
    groups = Groups.list_groups()
    render(conn, :index, groups: groups)
  end

  def new(conn, _params) do
    changeset = Group.changeset(%Group{}, %{})
    render(conn, :new, changeset: changeset, action: ~p"/groups")
  end

  def create(conn, %{"group" => group_params}) do
    case Groups.create_group(group_params) do
      {:ok, group} ->
        conn
        |> put_flash(:info, "Group created successfully.")
        |> redirect(to: ~p"/groups/#{group}")

      {:error, changeset} ->
        render(conn, :new, changeset: changeset)
    end
  end

  def show(conn, %{"id" => id}) do
    group = Groups.get_group!(id) |> Repo.preload([:members, :teams])
    render(conn, :show, group: group)
  end

  def edit(conn, %{"id" => id}) do
    group = Groups.get_group!(id)
    changeset = Group.changeset(group, %{})
    render(conn, :edit, group: group, changeset: changeset, action: ~p"/groups/#{group}")
  end

  def update(conn, %{"id" => id, "group" => group_params}) do
    group = Groups.get_group!(id)

    case Groups.update_group(group, group_params) do
      {:ok, group} ->
        conn
        |> put_flash(:info, "Group updated successfully.")
        |> redirect(to: ~p"/groups/#{group}")

      {:error, changeset} ->
        render(conn, :edit, group: group, changeset: changeset, action: ~p"/groups/#{group}")
    end
  end

  def delete(conn, %{"id" => id}) do
    group = Groups.get_group!(id)
    {:ok, _group} = Groups.delete_group(group)

    conn
    |> put_flash(:info, "Group deleted successfully.")
    |> redirect(to: ~p"/groups")
  end

  def add_member_form(conn, %{"id" => id}) do
    group = Groups.get_group!(id)
    render(conn, :add_member_form, group: group)
  end

  def add_member(conn, %{"id" => id, "email" => email}) do
    group = Groups.get_group!(id)
    
    case CommonLedger.Accounts.get_user_by_email(email) do
      nil ->
        conn
        |> put_flash(:error, "User not found")
        |> redirect(to: ~p"/groups/#{group}/add_member")
        
      user ->
        case Groups.add_member(group, user) do
          {:ok, _group} ->
            conn
            |> put_flash(:info, "Member added successfully")
            |> redirect(to: ~p"/groups/#{group}")
            
          {:error, _changeset} ->
            conn
            |> put_flash(:error, "Failed to add member")
            |> redirect(to: ~p"/groups/#{group}/add_member")
        end
    end
  end

  def remove_member(conn, %{"id" => group_id, "user_id" => user_id}) do
    group = Groups.get_group!(group_id)
    user = Accounts.get_user!(user_id)

    case Groups.remove_member(group, user) do
      {:ok, _group} ->
        conn
        |> put_flash(:info, "Member removed successfully")
        |> redirect(to: ~p"/groups/#{group}")

      {:error, _changeset} ->
        conn
        |> put_flash(:error, "Failed to remove member")
        |> redirect(to: ~p"/groups/#{group}")
    end
  end
end