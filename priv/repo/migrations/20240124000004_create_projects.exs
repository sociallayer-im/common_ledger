defmodule CommonLedger.Repo.Migrations.CreateProjects do
  use Ecto.Migration

  def change do
    create table(:projects) do
      add :name, :string, null: false
      add :group_id, references(:groups, on_delete: :delete_all), null: false

      timestamps()
    end

    create table(:project_members) do
      add :project_id, references(:projects, on_delete: :delete_all), null: false
      add :user_id, references(:users, type: :string, on_delete: :delete_all), null: false

      timestamps()
    end

    create index(:projects, [:group_id])
    create index(:project_members, [:project_id])
    create index(:project_members, [:user_id])
    create unique_index(:project_members, [:project_id, :user_id])
  end
end
