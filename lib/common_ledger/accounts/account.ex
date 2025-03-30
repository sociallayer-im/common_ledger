defmodule CommonLedger.Accounts.Account do
  use Ecto.Schema
  import Ecto.Changeset
  alias CommonLedger.Projects.Project

  schema "accounts" do
    field :name, :string
    field :currency_type, :string, default: "CNY"
    field :balance, :decimal, default: Decimal.new("0")

    belongs_to :project, Project, type: :string

    timestamps()
  end

  @currencies ~w(USD EUR GBP JPY CNY)

  def changeset(account, attrs) do
    account
    |> cast(attrs, [:name, :currency_type, :balance, :project_id])
    |> validate_required([:name, :currency_type, :project_id])
    |> validate_length(:name, min: 2, max: 160)
    |> validate_inclusion(:currency_type, @currencies)
    |> validate_number(:balance, greater_than_or_equal_to: 0)
    |> foreign_key_constraint(:project_id)
  end

  def currencies, do: @currencies
end
