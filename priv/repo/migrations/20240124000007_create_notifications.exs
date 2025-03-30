defmodule CommonLedger.Repo.Migrations.CreateNotifications do
  use Ecto.Migration

  def change do
    create table(:notifications) do
      add :type, :string, null: false
      add :content, :string, null: false
      add :read, :boolean, default: false, null: false
      add :user_id, references(:users, type: :string, on_delete: :delete_all), null: false

      timestamps()
    end

    create index(:notifications, [:user_id])
  end
end