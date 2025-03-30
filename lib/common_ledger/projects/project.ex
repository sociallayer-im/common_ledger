defmodule CommonLedger.Projects.Project do
  use Ecto.Schema
  import Ecto.Changeset
  alias CommonLedger.Groups.Group
  alias CommonLedger.Accounts.User

  @primary_key {:id, :string, autogenerate: false}
  schema "projects" do
    field :name, :string
    belongs_to :group, Group, type: :string
    many_to_many :members, User, join_through: "project_members"

    timestamps()
  end

  def changeset(project, attrs) do
    project
    |> ensure_id()
    |> cast(attrs, [:name, :group_id])
    |> validate_required([:name, :group_id])
    |> validate_length(:name, min: 2, max: 160)
    |> foreign_key_constraint(:group_id)
  end

  defp ensure_id(%{id: nil} = project) do
    %{project | id: TSID.generate()}
  end
  defp ensure_id(project), do: project
end