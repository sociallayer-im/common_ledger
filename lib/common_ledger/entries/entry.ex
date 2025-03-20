defmodule CommonLedger.Entries.Entry do
  use Ecto.Schema
  import Ecto.Changeset
  alias CommonLedger.Ledgers.Ledger

  schema "entries" do
    field :amount, :decimal
    field :currency, :string
    field :description, :string
    
    belongs_to :ledger, Ledger

    timestamps()
  end

  def changeset(entry, attrs) do
    entry
    |> cast(attrs, [:amount, :currency, :description, :ledger_id])
    |> validate_required([:amount, :currency, :ledger_id])
    |> validate_number(:amount, greater_than: 0)
    |> validate_inclusion(:currency, ~w(USD EUR GBP JPY CNY))
    |> foreign_key_constraint(:ledger_id)
  end
end