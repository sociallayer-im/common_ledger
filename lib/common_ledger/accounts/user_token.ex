defmodule CommonLedger.Accounts.UserToken do
  use Ecto.Schema
  import Ecto.Query
  import Ecto.Changeset

  @hash_algorithm :sha256
  @rand_size 32

  schema "users_tokens" do
    field :token, :binary
    field :context, :string
    field :sent_to, :string
    belongs_to :user, CommonLedger.Accounts.User

    timestamps(updated_at: false)
  end

  def build_email_token(user, context) do
    build_token(user, context, user.email)
  end

  defp build_token(user, context, sent_to) do
    token = :rand.uniform(900_000) + 100_000
    token_string = Integer.to_string(token)

    {token, %CommonLedger.Accounts.UserToken{
      token: token_string,
      context: context,
      sent_to: sent_to,
      user_id: user.id
    }}
  end
end
