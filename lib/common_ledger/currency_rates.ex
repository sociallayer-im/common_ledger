defmodule CommonLedger.CurrencyRates do
  import Ecto.Query
  alias CommonLedger.Repo
  alias CommonLedger.CurrencyRates.CurrencyRate

  def list_currency_rates do
    Repo.all(CurrencyRate)
  end

  def get_currency_rate!(id), do: Repo.get!(CurrencyRate, id)

  def create_currency_rate(attrs \\ %{}) do
    %CurrencyRate{}
    |> CurrencyRate.changeset(attrs)
    |> Repo.insert()
  end

  def update_currency_rate(%CurrencyRate{} = currency_rate, attrs) do
    currency_rate
    |> CurrencyRate.changeset(attrs)
    |> Repo.update()
  end

  def delete_currency_rate(%CurrencyRate{} = currency_rate) do
    Repo.delete(currency_rate)
  end

  def get_rate(from_currency, to_currency) do
    Repo.one(
      from cr in CurrencyRate,
        where: cr.from_currency == ^from_currency and cr.to_currency == ^to_currency,
        order_by: [desc: cr.last_updated_at],
        limit: 1,
        select: cr.rate
    )
  end
end
