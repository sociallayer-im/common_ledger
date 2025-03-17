defmodule CommonLedger.Repo.Migrations.CreateTransactions do
  use Ecto.Migration

  def change do
    create table(:transactions) do
      add :amount, :decimal, null: false
      add :currency, :string, null: false
      add :description, :string
      add :from_account_id, references(:accounts, on_delete: :nilify_all)
      add :to_account_id, references(:accounts, on_delete: :nilify_all)

      timestamps()
    end

    create index(:transactions, [:from_account_id])
    create index(:transactions, [:to_account_id])
  end
end