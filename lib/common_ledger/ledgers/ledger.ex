defmodule CommonLedger.Ledgers.Ledger do
  use Ecto.Schema
  import Ecto.Changeset
  alias CommonLedger.Teams.Team

  schema "ledgers" do
    field :name, :string
    field :description, :string
    field :currency_type, :string

    belongs_to :team, Team
    has_many :transactions, CommonLedger.Transactions.Transaction

    timestamps()
  end

  def changeset(ledger, attrs) do
    ledger
    |> cast(attrs, [:name, :description, :currency_type, :team_id])
    |> validate_required([:name, :currency_type, :team_id])
    |> validate_length(:name, min: 2, max: 160)
    |> validate_inclusion(:currency_type, ~w(USD EUR GBP JPY CNY))
    |> foreign_key_constraint(:team_id)
  end
end