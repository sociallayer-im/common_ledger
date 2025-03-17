defmodule CommonLedgerWeb.AuthController do
  use CommonLedgerWeb, :controller

  alias CommonLedger.Accounts

  def new(conn, _params) do
    render(conn, :new)
  end

  def login(conn, %{"email" => email}) do
    if user = Accounts.get_user_by_email(email) do
      Accounts.deliver_user_login_token(user)

      conn
      |> put_flash(:info, "Login link sent to your email.")
      |> redirect(to: ~p"/")
    else
      # Handle non-existent user case
      user_params = %{email: email}
      case Accounts.create_user(user_params) do
        {:ok, user} ->
          Accounts.deliver_user_login_token(user)

          conn
          |> put_flash(:info, "Login link sent to your email.")
          |> redirect(to: ~p"/")
        
        {:error, _changeset} ->
          conn
          |> put_flash(:error, "Invalid email format.")
          |> redirect(to: ~p"/auth/login")
      end
    end
  end

  def verify(conn, %{"token" => token}) do
    case Phoenix.Token.verify(CommonLedgerWeb.Endpoint, "user auth", token, max_age: 600) do
      {:ok, user_id} ->
        conn
        |> put_session(:user_id, user_id)
        |> configure_session(renew: true)
        |> redirect(to: ~p"/")

      {:error, _} ->
        conn
        |> put_flash(:error, "Invalid or expired login link")
        |> redirect(to: ~p"/auth/login")
    end
  end

  def logout(conn, _params) do
    conn
    |> configure_session(drop: true)
    |> redirect(to: ~p"/")
  end
end