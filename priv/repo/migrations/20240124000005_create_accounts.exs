defmodule CommonLedger.Repo.Migrations.CreateAccounts do
  use Ecto.Migration

  def change do
    create table(:accounts) do
      add :name, :string, null: false
      add :currency_type, :string, null: false
      add :balance, :decimal, null: false, default: 0
      add :team_id, references(:teams, on_delete: :delete_all), null: false

      timestamps()
    end

    create index(:accounts, [:team_id])
  end
end