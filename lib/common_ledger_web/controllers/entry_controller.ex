defmodule CommonLedgerWeb.EntryController do
  use CommonLedgerWeb, :controller

  alias CommonLedger.Entries
  alias CommonLedger.Entries.Entry
  alias CommonLedger.Ledgers

  def new(conn, %{"ledger_id" => ledger_id}) do
    ledger = Ledgers.get_ledger!(ledger_id)
    changeset = Entry.changeset(%Entry{ledger_id: ledger_id}, %{})
    render(conn, :new, changeset: changeset, ledger: ledger)
  end

  def create(conn, %{"ledger_id" => ledger_id, "entry" => entry_params}) do
    entry_params = Map.put(entry_params, "ledger_id", ledger_id)

    case Entries.create_entry(entry_params) do
      {:ok, _entry} ->
        conn
        |> put_flash(:info, "Entry created successfully.")
        |> redirect(to: ~p"/ledgers/#{ledger_id}")

      {:error, %Ecto.Changeset{} = changeset} ->
        ledger = Ledgers.get_ledger!(ledger_id)
        render(conn, :new, changeset: changeset, ledger: ledger)
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