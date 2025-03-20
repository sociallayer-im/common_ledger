defmodule CommonLedger.Repo.Migrations.CreateLedgers do
  use Ecto.Migration

  def change do
    create table(:ledgers) do
      add :name, :string, null: false
      add :description, :string
      add :currency_type, :string, null: false
      add :team_id, references(:teams, on_delete: :delete_all), null: false

      timestamps()
    end

    create index(:ledgers, [:team_id])

    # Update transactions to reference ledgers instead of accounts
    alter table(:transactions) do
      remove :from_account_id
      remove :to_account_id
      add :ledger_id, references(:ledgers, on_delete: :delete_all), null: false
    end

    create index(:transactions, [:ledger_id])
  end
end