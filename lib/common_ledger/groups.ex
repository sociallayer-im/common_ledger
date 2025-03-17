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
    group
    |> Repo.preload(:members)
    |> Ecto.Changeset.change()
    |> Ecto.Changeset.put_assoc(:members, [user | group.members])
    |> Repo.update()
  end

  def remove_member(%Group{} = group, %User{} = user) do
    group
    |> Repo.preload(:members)
    |> Ecto.Changeset.change()
    |> Ecto.Changeset.put_assoc(:members, Enum.reject(group.members, &(&1.id == user.id)))
    |> Repo.update()
  end
end