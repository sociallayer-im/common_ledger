defmodule CommonLedger.Accounts do
  import Ecto.Query
  alias CommonLedger.Repo
  alias CommonLedger.Accounts.{User, UserToken}

  def get_user_by_email(email) when is_binary(email) do
    Repo.get_by(User, email: email)
  end

  def get_user_by_email_and_token(email, token) do
    user = get_user_by_email(email)
    if user, do: {user, get_user_token(user, token)}
  end

  def create_user(attrs \\ %{}) do
    %User{}
    |> User.changeset(attrs)
    |> Repo.insert()
  end

  def generate_user_session_token(user) do
    {token, user_token} = UserToken.build_session_token(user)
    Repo.insert!(user_token)
    token
  end

  def get_user_by_session_token(token) do
    query =
      from token in UserToken,
        join: user in assoc(token, :user),
        where: token.context == "session",
        where: token.token == ^:crypto.hash(:sha256, token),
        select: user

    Repo.one(query)
  end

  def delete_user_session_token(token) do
    Repo.delete_all(UserToken.token_and_context_query(token, "session"))
    :ok
  end

  def deliver_user_login_token(user) do
    {token, _user_token} = UserToken.build_email_token(user, "login")
    url = "http://localhost:4000/auth/login/#{token}"
    IO.inspect("token")
    IO.inspect(token)

    CommonLedger.Email.deliver_login_link(user, url)
  end

  defp get_user_token(user, token) do
    query =
      from token in UserToken,
        where: token.user_id == ^user.id,
        where: token.context == "login"

    Repo.one(query)
  end

  def get_user!(id), do: Repo.get!(User, id)
end
