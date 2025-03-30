defmodule CommonLedger.Accounts.User do
  use Ecto.Schema
  import Ecto.Changeset
  alias CommonLedger.Groups.Group

  @primary_key {:id, :string, autogenerate: false}
  schema "users" do
    field :email, :string
    field :name, :string
    field :confirmed_at, :naive_datetime

    many_to_many :groups, Group, join_through: "group_members"

    timestamps()
  end

  def changeset(user, attrs) do
    user
    |> ensure_id()
    |> cast(attrs, [:email, :name])
    |> validate_required([:email])
    |> validate_email()
  end

  defp validate_email(changeset) do
    changeset
    |> validate_format(:email, ~r/^[^\s]+@[^\s]+$/, message: "must have the @ sign and no spaces")
    |> validate_length(:email, max: 160)
    |> unique_constraint(:email)
  end

  defp ensure_id(%{id: nil} = user) do
    %{user | id: TSID.generate()}
  end
  defp ensure_id(user), do: user
end