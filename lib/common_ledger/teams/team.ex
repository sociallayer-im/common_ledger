defmodule CommonLedger.Teams.Team do
  use Ecto.Schema
  import Ecto.Changeset
  alias CommonLedger.Groups.Group
  alias CommonLedger.Accounts.User
  alias CommonLedger.Ledgers.Ledger

  schema "teams" do
    field :name, :string
    belongs_to :group, Group
    many_to_many :members, User, join_through: "team_members"
    has_many :ledgers, Ledger

    timestamps()
  end

  def changeset(team, attrs) do
    team
    |> cast(attrs, [:name, :group_id])
    |> validate_required([:name, :group_id])
    |> validate_length(:name, min: 2, max: 160)
    |> foreign_key_constraint(:group_id)
  end
end