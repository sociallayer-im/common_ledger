defmodule CommonLedger.Ledgers.Ledger do
  use Ecto.Schema
  import Ecto.Changeset
  alias CommonLedger.Projects.Project

  schema "ledgers" do
    field :name, :string
    field :description, :string
    field :currency_type, :string

    belongs_to :project, Project
    has_many :transactions, CommonLedger.Transactions.Transaction

    timestamps()
  end

  def changeset(ledger, attrs) do
    ledger
    |> cast(attrs, [:name, :description, :currency_type, :project_id])
    |> validate_required([:name, :currency_type, :project_id])
    |> validate_length(:name, min: 2, max: 160)
    |> validate_inclusion(:currency_type, ~w(USD EUR GBP JPY CNY))
    |> foreign_key_constraint(:project_id)
  end
end
