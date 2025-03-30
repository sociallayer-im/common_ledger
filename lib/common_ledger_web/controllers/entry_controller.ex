defmodule CommonLedgerWeb.EntryController do
  use CommonLedgerWeb, :controller

  alias CommonLedger.Entries
  alias CommonLedger.Entries.Entry
  alias CommonLedger.Ledgers
  alias CommonLedger.Accounts.Accounts
  alias CommonLedgerWeb.AuthHelper

  def new(conn, %{"ledger_id" => ledger_id}) do
    ledger = Ledgers.get_ledger!(ledger_id)
    
    case AuthHelper.ensure_project_member(conn, ledger.project_id) do
      {:ok, conn} ->
        accounts = Accounts.list_accounts_by_project(ledger.project_id)
        changeset = Entry.changeset(%Entry{ledger_id: ledger_id}, %{})
        render(conn, :new, changeset: changeset, ledger: ledger, accounts: accounts)

      {:error, :unauthorized} ->
        conn
        |> put_flash(:error, "You must be a project member to create entries")
        |> redirect(to: ~p"/ledgers/#{ledger_id}")
    end
  end

  def create(conn, %{"ledger_id" => ledger_id, "entry" => entry_params}) do
    ledger = Ledgers.get_ledger!(ledger_id)
    
    case AuthHelper.ensure_project_member(conn, ledger.project_id) do
      {:ok, conn} ->
        entry_params = Map.put(entry_params, "ledger_id", ledger_id)

        case Entries.create_entry(entry_params) do
          {:ok, _entry} ->
            conn
            |> put_flash(:info, "Entry created successfully.")
            |> redirect(to: ~p"/ledgers/#{ledger_id}")

          {:error, %Ecto.Changeset{} = changeset} ->
            accounts = Accounts.list_accounts_by_project(ledger.project_id)
            render(conn, :new, changeset: changeset, ledger: ledger, accounts: accounts)
        end

      {:error, :unauthorized} ->
        conn
        |> put_flash(:error, "You must be a project member to create entries")
        |> redirect(to: ~p"/ledgers/#{ledger_id}")
    end
  end

  def edit(conn, %{"id" => id}) do
    entry = Entries.get_entry!(id)
    ledger = Ledgers.get_ledger!(entry.ledger_id)
    accounts = Accounts.list_accounts_by_project(ledger.project_id)
    changeset = Entries.change_entry(entry)
    render(conn, :edit, entry: entry, changeset: changeset, ledger: ledger, accounts: accounts)
  end

  def update(conn, %{"id" => id, "entry" => entry_params}) do
    entry = Entries.get_entry!(id)

    case Entries.update_entry(entry, entry_params) do
      {:ok, entry} ->
        conn
        |> put_flash(:info, "Entry updated successfully.")
        |> redirect(to: ~p"/ledgers/#{entry.ledger_id}")

      {:error, %Ecto.Changeset{} = changeset} ->
        ledger = Ledgers.get_ledger!(entry.ledger_id)
        accounts = Accounts.list_accounts_by_project(ledger.project_id)
        render(conn, :edit, entry: entry, changeset: changeset, ledger: ledger, accounts: accounts)
    end
  end

  def delete(conn, %{"id" => id}) do
    entry = Entries.get_entry!(id)
    {:ok, _entry} = Entries.delete_entry(entry)

    conn
    |> put_flash(:info, "Entry deleted successfully.")
    |> redirect(to: ~p"/ledgers/#{entry.ledger_id}")
  end
end
