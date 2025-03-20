defmodule CommonLedger.Groups do
  import Ecto.Query
  alias CommonLedger.Repo
  alias CommonLedger.Groups.Group
  alias CommonLedger.Accounts.User

  def list_groups do
    Repo.all(Group)
  end

  def get_group!(id), do: Repo.get!(Group, id)

  def create_group(attrs \\ %{}) do
    %Group{}
    |> Group.changeset(attrs)
    |> Repo.insert()
  end

  def update_group(%Group{} = group, attrs) do
    group
    |> Group.changeset(attrs)
    |> Repo.update()
  end

  def delete_group(%Group{} = group) do
    Repo.delete(group)
  end

  def add_member(%Group{} = group, %User{} = user) do
    group = Repo.preload(group, :members)
    
    # Check if user is already a member
    if Enum.any?(group.members, fn member -> member.id == user.id end) do
      {:error, :already_member}
    else
      # Insert into join table directly
      Repo.insert_all("group_members", [%{
        group_id: group.id,
        user_id: user.id,
        inserted_at: NaiveDateTime.utc_now() |> NaiveDateTime.truncate(:second),
        updated_at: NaiveDateTime.utc_now() |> NaiveDateTime.truncate(:second)
      }])
      {:ok, group}
    end
  end

  def remove_member(%Group{} = group, %User{} = user) do
    # Delete directly from the join table
    {count, _} = Repo.delete_all(from gm in "group_members",
      where: gm.group_id == ^group.id and gm.user_id == ^user.id)
    
    if count > 0 do
      {:ok, group}
    else
      {:error, :not_member}
    end
  end
end