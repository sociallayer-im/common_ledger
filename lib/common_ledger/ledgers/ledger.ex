defmodule CommonLedger.Ledgers.Ledger do
  use Ecto.Schema
  import Ecto.Changeset
  alias CommonLedger.Projects.Project

  @primary_key {:id, :string, autogenerate: false}
  schema "ledgers" do
    field :name, :string
    field :description, :string
    field :currency_type, :string, default: "CNY"

    belongs_to :project, Project, type: :string
    has_many :entries, CommonLedger.Entries.Entry

    timestamps()
  end

  @currencies ~w(USD EUR GBP JPY CNY)

  def changeset(ledger, attrs) do
    ledger
    |> ensure_id()
    |> cast(attrs, [:name, :description, :currency_type, :project_id])
    |> validate_required([:name, :currency_type, :project_id])
    |> validate_length(:name, min: 2, max: 160)
    |> validate_inclusion(:currency_type, @currencies)
    |> foreign_key_constraint(:project_id)
  end

  def currencies, do: @currencies

  defp ensure_id(%{id: nil} = ledger) do
    %{ledger | id: TSID.generate()}
  end

  defp ensure_id(ledger), do: ledger
end
