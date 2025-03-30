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
      |> put_session(:login_email, email)
      |> put_flash(:info, "Verification code sent to your email.")
      |> redirect(to: ~p"/auth/verify")
    else
      # Handle non-existent user case
      user_params = %{email: email}

      case Accounts.create_user(user_params) do
        {:ok, user} ->
          Accounts.deliver_user_login_token(user)

          conn
          |> put_session(:login_email, email)
          |> put_flash(:info, "Verification code sent to your email.")
          |> redirect(to: ~p"/auth/verify")

        {:error, _changeset} ->
          conn
          |> put_flash(:error, "Invalid email format.")
          |> redirect(to: ~p"/auth/login")
      end
    end
  end

  def verify_form(conn, _params) do
    case get_session(conn, :login_email) do
      nil ->
        conn
        |> put_flash(:error, "Please enter your email first")
        |> redirect(to: ~p"/auth/login")

      email ->
        render(conn, :verify, email: email)
    end
  end

  def verify(conn, %{"code" => code}) do
    email = get_session(conn, :login_email)

    case Accounts.get_user_by_email_and_token(email, code) do
      {user, _token} ->
        token = Accounts.generate_user_session_token(user)

        conn
        |> delete_session(:login_email)
        |> put_session(:user_token, token)
        |> configure_session(renew: true)
        |> put_flash(:info, "Welcome back!")
        |> redirect(to: ~p"/")

      nil ->
        conn
        |> put_flash(:error, "Invalid or expired verification code")
        |> redirect(to: ~p"/auth/verify")
    end
  end

  def logout(conn, _params) do
    if user_token = get_session(conn, :user_token) do
      Accounts.delete_user_session_token(user_token)
    end

    conn
    |> delete_session(:user_token)
    |> configure_session(drop: true)
    |> redirect(to: ~p"/")
  end
end
