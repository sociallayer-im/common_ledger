defmodule CommonLedger.Repo.Migrations.CreateTeams do
  use Ecto.Migration

  def change do
    create table(:teams) do
      add :name, :string, null: false
      add :group_id, references(:groups, on_delete: :delete_all), null: false

      timestamps()
    end

    create table(:team_members) do
      add :team_id, references(:teams, on_delete: :delete_all), null: false
      add :user_id, references(:users, on_delete: :delete_all), null: false

      timestamps()
    end

    create index(:teams, [:group_id])
    create index(:team_members, [:team_id])
    create index(:team_members, [:user_id])
    create unique_index(:team_members, [:team_id, :user_id])
  end
end