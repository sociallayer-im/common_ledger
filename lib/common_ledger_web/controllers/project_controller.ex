defmodule CommonLedgerWeb.ProjectController do
  use CommonLedgerWeb, :controller

  alias CommonLedger.Projects
  alias CommonLedger.Projects.Project
  alias CommonLedger.Groups
  alias CommonLedger.Accounts
  alias CommonLedger.Ledgers

  def new(conn, %{"group_id" => group_id}) do
    group = Groups.get_group!(group_id)
    changeset = Project.changeset(%Project{group_id: group_id}, %{})
    render(conn, :new, changeset: changeset, group: group)
  end

  def create(conn, %{"group_id" => group_id, "project" => project_params}) do
    project_params = Map.put(project_params, "group_id", group_id)

    case Projects.create_project(project_params) do
      {:ok, project} ->
        conn
        |> put_flash(:info, "Project created successfully.")
        |> redirect(to: ~p"/groups/#{group_id}")

      {:error, %Ecto.Changeset{} = changeset} ->
        group = Groups.get_group!(group_id)
        render(conn, :new, changeset: changeset, group: group)
    end
  end

  def show(conn, %{"id" => id}) do
    project = Projects.get_project!(id) |> CommonLedger.Repo.preload([:members])
    group = Groups.get_group!(project.group_id)
    ledgers = CommonLedger.Ledgers.list_ledgers_by_project(project.id)
    render(conn, :show, project: project, group: group, ledgers: ledgers)
  end

  def edit(conn, %{"id" => id}) do
    project = Projects.get_project!(id)
    changeset = Project.changeset(project, %{})
    render(conn, :edit, project: project, changeset: changeset)
  end

  def update(conn, %{"id" => id, "project" => project_params}) do
    project = Projects.get_project!(id)

    case Projects.update_project(project, project_params) do
      {:ok, project} ->
        conn
        |> put_flash(:info, "Project updated successfully.")
        |> redirect(to: ~p"/projects/#{project}")

      {:error, %Ecto.Changeset{} = changeset} ->
        render(conn, :edit, project: project, changeset: changeset)
    end
  end

  def delete(conn, %{"id" => id}) do
    project = Projects.get_project!(id)
    {:ok, _project} = Projects.delete_project(project)

    conn
    |> put_flash(:info, "Project deleted successfully.")
    |> redirect(to: ~p"/groups/#{project.group_id}")
  end

  def add_member_form(conn, %{"id" => id}) do
    project = Projects.get_project!(id)
    render(conn, :add_member_form, project: project)
  end

  def add_member(conn, %{"id" => id, "email" => email}) do
    project = Projects.get_project!(id)

    case Accounts.get_user_by_email(email) do
      nil ->
        conn
        |> put_flash(:error, "User not found")
        |> redirect(to: ~p"/projects/#{project}/add_member")

      user ->
        case Projects.add_member(project, user) do
          {:ok, _project} ->
            conn
            |> put_flash(:info, "Member added successfully")
            |> redirect(to: ~p"/projects/#{project}")

          {:error, _changeset} ->
            conn
            |> put_flash(:error, "Failed to add member")
            |> redirect(to: ~p"/projects/#{project}/add_member")
        end
    end
  end

  def remove_member(conn, %{"id" => project_id, "user_id" => user_id}) do
    project = Projects.get_project!(project_id)
    user = Accounts.get_user!(user_id)

    case Projects.remove_member(project, user) do
      {:ok, _project} ->
        conn
        |> put_flash(:info, "Member removed successfully")
        |> redirect(to: ~p"/projects/#{project}")

      {:error, _changeset} ->
        conn
        |> put_flash(:error, "Failed to remove member")
        |> redirect(to: ~p"/projects/#{project}")
    end
  end
end