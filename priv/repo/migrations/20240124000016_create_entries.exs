defmodule CommonLedger.Repo.Migrations.CreateEntries do
  use Ecto.Migration

  def change do
    create table(:entries, primary_key: false) do
      add :id, :string, primary_key: true
      add :amount, :decimal, null: false
      add :currency, :string, null: false
      add :description, :string
      add :memo, :string
      add :category, :string
      add :ledger_id, references(:ledgers, type: :string, on_delete: :nilify_all)
      add :account_id, references(:accounts, type: :string, on_delete: :nilify_all)

      timestamps()
    end

    create index(:entries, [:ledger_id])
    create index(:entries, [:account_id])
  end
end
