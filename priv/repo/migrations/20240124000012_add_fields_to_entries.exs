defmodule CommonLedger.Repo.Migrations.AddFieldsToEntries do
  use Ecto.Migration

  def change do
    alter table(:entries) do
      add :account_id, references(:accounts, on_delete: :delete_all)
      add :category, :string
      add :memo, :text
    end

    create index(:entries, [:account_id])
  end
end
