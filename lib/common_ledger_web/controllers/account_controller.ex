defmodule CommonLedgerWeb.AccountController do
  use CommonLedgerWeb, :controller

  alias CommonLedger.Accounts.Accounts
  alias CommonLedger.Accounts.Account
  alias CommonLedger.Projects
  alias CommonLedger.Entries
  alias CommonLedger.Repo
  alias CommonLedgerWeb.AuthHelper
  import Ecto.Query

  def new(conn, %{"project_id" => project_id}) do
    project = Projects.get_project!(project_id)
    
    case AuthHelper.ensure_group_member(conn, project.group_id) do
      {:ok, conn} ->
        changeset = Account.changeset(%Account{project_id: project_id}, %{})
        render(conn, :new, changeset: changeset, project: project)
      
      {:error, :unauthorized} ->
        conn
        |> put_flash(:error, "You must be a group member to create accounts")
        |> redirect(to: ~p"/projects/#{project_id}")
    end
  end

  def create(conn, %{"project_id" => project_id, "account" => account_params}) do
    project = Projects.get_project!(project_id)
    
    case AuthHelper.ensure_group_member(conn, project.group_id) do
      {:ok, conn} ->
        account_params = Map.put(account_params, "project_id", project_id)

        case Accounts.create_account(account_params) do
          {:ok, _account} ->
            conn
            |> put_flash(:info, "Account created successfully.")
            |> redirect(to: ~p"/projects/#{project_id}")

          {:error, %Ecto.Changeset{} = changeset} ->
            render(conn, :new, changeset: changeset, project: project)
        end

      {:error, :unauthorized} ->
        conn
        |> put_flash(:error, "You must be a group member to create accounts")
        |> redirect(to: ~p"/projects/#{project_id}")
    end
  end

  def edit(conn, %{"id" => id}) do
    account = Accounts.get_account!(id)
    project = Projects.get_project!(account.project_id)
    changeset = Accounts.change_account(account)

    # Calculate sums by currency
    sums_by_currency = from(e in CommonLedger.Entries.Entry,
      where: e.account_id == ^account.id,
      group_by: e.currency,
      select: {e.currency, sum(e.amount)}
    ) |> Repo.all()

    render(conn, :edit, 
      account: account, 
      changeset: changeset, 
      project: project, 
      sums_by_currency: sums_by_currency
    )
  end

  def update(conn, %{"id" => id, "account" => account_params}) do
    account = Accounts.get_account!(id)

    case Accounts.update_account(account, account_params) do
      {:ok, account} ->
        conn
        |> put_flash(:info, "Account updated successfully.")
        |> redirect(to: ~p"/projects/#{account.project_id}")

      {:error, %Ecto.Changeset{} = changeset} ->
        project = Projects.get_project!(account.project_id)
        # Recalculate sums in case of error
        sums_by_currency = from(e in CommonLedger.Entries.Entry,
          where: e.account_id == ^account.id,
          group_by: e.currency,
          select: {e.currency, sum(e.amount)}
        ) |> Repo.all()
        render(conn, :edit, 
          account: account, 
          changeset: changeset, 
          project: project, 
          sums_by_currency: sums_by_currency
        )
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