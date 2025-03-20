defmodule CommonLedger.Teams do
  import Ecto.Query
  alias CommonLedger.Repo
  alias CommonLedger.Teams.Team
  alias CommonLedger.Accounts.User

  def list_teams_by_group(group_id) do
    Repo.all(from t in Team, where: t.group_id == ^group_id)
  end

  def get_team!(id), do: Repo.get!(Team, id)

  def create_team(attrs \\ %{}) do
    %Team{}
    |> Team.changeset(attrs)
    |> Repo.insert()
  end

  def update_team(%Team{} = team, attrs) do
    team
    |> Team.changeset(attrs)
    |> Repo.update()
  end

  def delete_team(%Team{} = team) do
    Repo.delete(team)
  end

  def add_member(%Team{} = team, %User{} = user) do
    team = Repo.preload(team, :members)
    
    if Enum.any?(team.members, fn member -> member.id == user.id end) do
      {:error, :already_member}
    else
      Repo.insert_all("team_members", [%{
        team_id: team.id,
        user_id: user.id,
        inserted_at: NaiveDateTime.utc_now() |> NaiveDateTime.truncate(:second),
        updated_at: NaiveDateTime.utc_now() |> NaiveDateTime.truncate(:second)
      }])
      {:ok, team}
    end
  end

  def remove_member(%Team{} = team, %User{} = user) do
    {count, _} = Repo.delete_all(from tm in "team_members",
      where: tm.team_id == ^team.id and tm.user_id == ^user.id)
    
    if count > 0 do
      {:ok, team}
    else
      {:error, :not_member}
    end
  end
end