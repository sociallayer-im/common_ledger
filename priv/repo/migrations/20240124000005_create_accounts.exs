defmodule CommonLedger.Repo.Migrations.CreateAccounts do
  use Ecto.Migration

  def change do
    create table(:accounts) do
      add :name, :string, null: false
      add :currency_type, :string, null: false
      add :balance, :decimal, null: false, default: 0
      add :project_id, references(:projects, type: :string, on_delete: :delete_all), null: false

      timestamps()
    end

    create index(:accounts, [:project_id])
  end
end
