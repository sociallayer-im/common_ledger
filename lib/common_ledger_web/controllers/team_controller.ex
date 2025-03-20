defmodule CommonLedgerWeb.TeamController do
  use CommonLedgerWeb, :controller

  alias CommonLedger.Teams
  alias CommonLedger.Teams.Team
  alias CommonLedger.Groups

  def new(conn, %{"group_id" => group_id}) do
    group = Groups.get_group!(group_id)
    changeset = Team.changeset(%Team{group_id: group_id}, %{})
    render(conn, :new, changeset: changeset, group: group)
  end

  def create(conn, %{"group_id" => group_id, "team" => team_params}) do
    team_params = Map.put(team_params, "group_id", group_id)

    case Teams.create_team(team_params) do
      {:ok, team} ->
        conn
        |> put_flash(:info, "Team created successfully.")
        |> redirect(to: ~p"/groups/#{group_id}")

      {:error, %Ecto.Changeset{} = changeset} ->
        group = Groups.get_group!(group_id)
        render(conn, :new, changeset: changeset, group: group)
    end
  end

  def show(conn, %{"id" => id}) do
    team = Teams.get_team!(id)
    render(conn, :show, team: team)
  end

  def edit(conn, %{"id" => id}) do
    team = Teams.get_team!(id)
    changeset = Team.changeset(team, %{})
    render(conn, :edit, team: team, changeset: changeset)
  end

  def update(conn, %{"id" => id, "team" => team_params}) do
    team = Teams.get_team!(id)

    case Teams.update_team(team, team_params) do
      {:ok, team} ->
        conn
        |> put_flash(:info, "Team updated successfully.")
        |> redirect(to: ~p"/teams/#{team}")

      {:error, %Ecto.Changeset{} = changeset} ->
        render(conn, :edit, team: team, changeset: changeset)
    end
  end

  def delete(conn, %{"id" => id}) do
    team = Teams.get_team!(id)
    {:ok, _team} = Teams.delete_team(team)

    conn
    |> put_flash(:info, "Team deleted successfully.")
    |> redirect(to: ~p"/groups/#{team.group_id}")
  end
end