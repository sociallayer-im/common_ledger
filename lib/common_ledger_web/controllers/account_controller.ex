defmodule CommonLedgerWeb.AccountController do
  use CommonLedgerWeb, :controller

  alias CommonLedger.Accounts.Accounts
  alias CommonLedger.Accounts.Account
  alias CommonLedger.Projects

  def new(conn, %{"project_id" => project_id}) do
    project = Projects.get_project!(project_id)
    changeset = Account.changeset(%Account{project_id: project_id}, %{})
    render(conn, :new, changeset: changeset, project: project)
  end

  def create(conn, %{"project_id" => project_id, "account" => account_params}) do
    account_params = Map.put(account_params, "project_id", project_id)

    case Accounts.create_account(account_params) do
      {:ok, _account} ->
        conn
        |> put_flash(:info, "Account created successfully.")
        |> redirect(to: ~p"/projects/#{project_id}")

      {:error, %Ecto.Changeset{} = changeset} ->
        project = Projects.get_project!(project_id)
        render(conn, :new, changeset: changeset, project: project)
    end
  end

  def delete(conn, %{"id" => id}) do
    account = Accounts.get_account!(id)
    {:ok, _account} = Accounts.delete_account(account)

    conn
    |> put_flash(:info, "Account deleted successfully.")
    |> redirect(to: ~p"/projects/#{account.project_id}")
  end
end