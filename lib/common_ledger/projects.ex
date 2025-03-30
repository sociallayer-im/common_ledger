defmodule CommonLedger.Projects do
  import Ecto.Query
  alias CommonLedger.Repo
  alias CommonLedger.Projects.Project
  alias CommonLedger.Accounts.User

  def list_projects_by_group(group_id) do
    Repo.all(from p in Project, where: p.group_id == ^group_id)
  end

  def get_project!(id), do: Repo.get!(Project, id)

  def create_project(attrs \\ %{}) do
    %Project{}
    |> Project.changeset(attrs)
    |> Repo.insert()
  end

  def update_project(%Project{} = project, attrs) do
    project
    |> Project.changeset(attrs)
    |> Repo.update()
  end

  def delete_project(%Project{} = project) do
    Repo.delete(project)
  end

  def add_member(%Project{} = project, %User{} = user) do
    project = Repo.preload(project, :members)

    if Enum.any?(project.members, fn member -> member.id == user.id end) do
      {:error, :already_member}
    else
      Repo.insert_all("project_members", [
        %{
          project_id: project.id,
          user_id: user.id,
          inserted_at: NaiveDateTime.utc_now() |> NaiveDateTime.truncate(:second),
          updated_at: NaiveDateTime.utc_now() |> NaiveDateTime.truncate(:second)
        }
      ])

      {:ok, project}
    end
  end

  def remove_member(%Project{} = project, %User{} = user) do
    {count, _} =
      Repo.delete_all(
        from pm in "project_members",
          where: pm.project_id == ^project.id and pm.user_id == ^user.id
      )

    if count > 0 do
      {:ok, project}
    else
      {:error, :not_member}
    end
  end
end
