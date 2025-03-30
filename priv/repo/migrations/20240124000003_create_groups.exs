defmodule CommonLedger.Repo.Migrations.CreateGroups do
  use Ecto.Migration

  def change do
    create table(:groups, primary_key: false) do
      add :id, :string, primary_key: true
      add :name, :string, null: false
      add :description, :string

      timestamps()
    end

    create table(:group_members) do
      add :group_id, references(:groups, type: :string, on_delete: :delete_all), null: false
      add :user_id, references(:users, type: :string, on_delete: :delete_all), null: false

      timestamps()
    end

    create index(:group_members, [:group_id])
    create index(:group_members, [:user_id])
    create unique_index(:group_members, [:group_id, :user_id])
  end
end