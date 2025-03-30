defmodule CommonLedger.Groups.Group do
  use Ecto.Schema
  import Ecto.Changeset
  alias CommonLedger.Accounts.User
  alias CommonLedger.Projects.Project

  @primary_key {:id, :string, autogenerate: false}
  schema "groups" do
    field :name, :string
    field :description, :string
    
    many_to_many :members, User, join_through: "group_members"
    has_many :projects, Project
    
    timestamps()
  end

  def changeset(group, attrs) do
    group
    |> ensure_id()
    |> cast(attrs, [:name, :description])
    |> validate_required([:name])
    |> validate_length(:name, min: 2, max: 160)
  end

  defp ensure_id(%{id: nil} = group) do
    %{group | id: TSID.generate()}
  end
  defp ensure_id(group), do: group
end