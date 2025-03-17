defmodule CommonLedger.Groups.Group do
  use Ecto.Schema
  import Ecto.Changeset
  alias CommonLedger.Accounts.User

  schema "groups" do
    field :name, :string
    field :description, :string
    
    timestamps()
  end

  def changeset(group, attrs) do
    group
    |> cast(attrs, [:name, :description])
    |> validate_required([:name])
    |> validate_length(:name, min: 2, max: 160)
  end
end