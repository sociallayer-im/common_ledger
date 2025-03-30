defmodule CommonLedgerWeb.AuthHelper do
  alias CommonLedger.Groups
  alias CommonLedger.Projects
  alias CommonLedger.Repo

  def is_group_member?(group_id, user_id) do
    group = Groups.get_group!(group_id) |> Repo.preload(:members)
    Enum.any?(group.members, fn member -> member.id == user_id end)
  end

  def is_project_member?(project_id, user_id) do
    project = Projects.get_project!(project_id) |> Repo.preload(:members)
    Enum.any?(project.members, fn member -> member.id == user_id end)
  end

  def ensure_group_member(conn, group_id) do
    if is_group_member?(group_id, conn.assigns.current_user.id) do
      {:ok, conn}
    else
      {:error, :unauthorized}
    end
  end

  def ensure_project_member(conn, project_id) do
    if is_project_member?(project_id, conn.assigns.current_user.id) do
      {:ok, conn}
    else
      {:error, :unauthorized}
    end
  end
end