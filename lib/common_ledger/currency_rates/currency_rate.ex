defmodule CommonLedger.CurrencyRates.CurrencyRate do
  use Ecto.Schema
  import Ecto.Changeset

  @primary_key {:id, :string, autogenerate: false}
  schema "currency_rates" do
    field :from_currency, :string
    field :to_currency, :string
    field :rate, :decimal
    field :last_updated_at, :utc_datetime

    timestamps()
  end

  @currencies ~w(USD EUR GBP JPY CNY)

  def changeset(currency_rate, attrs) do
    currency_rate
    |> ensure_id()
    |> cast(attrs, [:from_currency, :to_currency, :rate, :last_updated_at])
    |> validate_required([:from_currency, :to_currency, :rate, :last_updated_at])
    |> validate_inclusion(:from_currency, @currencies)
    |> validate_inclusion(:to_currency, @currencies)
    |> validate_number(:rate, greater_than: 0)
  end

  defp ensure_id(%{id: nil} = currency_rate) do
    %{currency_rate | id: TSID.generate()}
  end

  defp ensure_id(currency_rate), do: currency_rate
end
