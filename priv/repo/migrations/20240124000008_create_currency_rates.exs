defmodule CommonLedger.Repo.Migrations.CreateCurrencyRates do
  use Ecto.Migration

  def change do
    create table(:currency_rates) do
      add :from_currency, :string, null: false
      add :to_currency, :string, null: false
      add :rate, :decimal, null: false
      add :last_updated_at, :utc_datetime, null: false

      timestamps()
    end

    create index(:currency_rates, [:from_currency, :to_currency])
  end
end