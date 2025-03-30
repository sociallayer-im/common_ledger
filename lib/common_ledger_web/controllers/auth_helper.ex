defmodule CommonLedgerWeb.AuthHelper do
  alias CommonLedger.Groups
  alias CommonLedger.Projects
  alias CommonLedger.Repo
  import Ecto.Query

  def is_group_member?(group_id, user_id) do
    query = from gm in "group_members",
      where: gm.group_id == ^group_id and gm.user_id == ^user_id,
      select: count(gm.user_id)
    
    result = Repo.one(query)
    IO.inspect("Checking membership for:")
    IO.inspect(%{group_id: group_id, user_id: user_id, count: result})
    
    result > 0
  end

  def is_project_member?(project_id, user_id) do
    query = from pm in "project_members",
      where: pm.project_id == ^project_id and pm.user_id == ^user_id,
      select: count(pm.user_id)
    
    Repo.one(query) > 0
  end

  def ensure_group_member(conn, group_id) do
    user = conn.assigns.current_user
    IO.inspect("Current user:")
    IO.inspect(user)
    
    # First try direct group membership
    if is_group_member?(group_id, user.id) do
      {:ok, conn}
    else
      # If not a direct member, check if they're a member of any project in the group
      project_query = from p in CommonLedger.Projects.Project,
        where: p.group_id == ^group_id,
        select: p.id
      
      project_ids = Repo.all(project_query)
      
      is_member_of_any_project = Enum.any?(project_ids, fn pid -> 
        is_project_member?(pid, user.id)
      end)
      
      if is_member_of_any_project do
        {:ok, conn}
      else
        {:error, :unauthorized}
      end
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
