defmodule CommonLedger.Entries.Entry do
  use Ecto.Schema
  import Ecto.Changeset
  alias CommonLedger.Ledgers.Ledger
  alias CommonLedger.Accounts.Account

  @primary_key {:id, :string, autogenerate: false}
  schema "entries" do
    field :amount, :decimal
    field :currency, :string
    field :description, :string
    field :memo, :string
    field :category, :string

    belongs_to :ledger, Ledger, type: :string
    belongs_to :account, Account, type: :string

    timestamps()
  end

  def changeset(entry, attrs) do
    entry
    |> ensure_id()
    |> cast(attrs, [:amount, :currency, :description, :ledger_id, :account_id, :memo, :category])
    |> validate_required([:amount, :currency, :ledger_id, :account_id])
    |> validate_inclusion(:currency, ~w(USD EUR GBP JPY CNY))
    |> foreign_key_constraint(:ledger_id)
    |> foreign_key_constraint(:account_id)
  end

  defp ensure_id(%{id: nil} = entry) do
    %{entry | id: TSID.generate()}
  end

  defp ensure_id(entry), do: entry
end
