defmodule CommonLedger.Repo.Migrations.CreateLedgers do
  use Ecto.Migration

  def change do
    create table(:ledgers, primary_key: false) do
      add :id, :string, primary_key: true
      add :name, :string, null: false
      add :description, :string
      add :currency_type, :string, null: false
      add :project_id, references(:projects, type: :string, on_delete: :delete_all), null: false

      timestamps()
    end

    create index(:ledgers, [:project_id])

    # Update entries to reference ledgers instead of accounts
    alter table(:entries) do
      remove :from_account_id
      remove :to_account_id
      add :ledger_id, references(:ledgers, type: :string, on_delete: :delete_all), null: false
    end

    create index(:entries, [:ledger_id])
  end
end
