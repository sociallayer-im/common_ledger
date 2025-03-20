defmodule CommonLedgerWeb.LedgerController do
  use CommonLedgerWeb, :controller

  alias CommonLedger.Ledgers
  alias CommonLedger.Ledgers.Ledger
  alias CommonLedger.Projects
  alias CommonLedger.Entries

  def new(conn, %{"project_id" => project_id}) do
    project = Projects.get_project!(project_id)
    changeset = Ledger.changeset(%Ledger{project_id: project_id}, %{})
    render(conn, :new, changeset: changeset, project: project)
  end

  def create(conn, %{"project_id" => project_id, "ledger" => ledger_params}) do
    ledger_params = Map.put(ledger_params, "project_id", project_id)

    case Ledgers.create_ledger(ledger_params) do
      {:ok, _ledger} ->
        conn
        |> put_flash(:info, "Ledger created successfully.")
        |> redirect(to: ~p"/projects/#{project_id}")

      {:error, %Ecto.Changeset{} = changeset} ->
        project = Projects.get_project!(project_id)
        render(conn, :new, changeset: changeset, project: project)
    end
  end

  def show(conn, %{"id" => id}) do
    ledger = Ledgers.get_ledger!(id)
    project = Projects.get_project!(ledger.project_id)
    entries = Entries.list_entries_by_ledger(id)
    render(conn, :show, ledger: ledger, project: project, entries: entries)
  end

  def edit(conn, %{"id" => id}) do
    ledger = Ledgers.get_ledger!(id)
    project = Projects.get_project!(ledger.project_id)
    changeset = Ledger.changeset(ledger, %{})
    render(conn, :edit, ledger: ledger, changeset: changeset, project: project)
  end

  def update(conn, %{"id" => id, "ledger" => ledger_params}) do
    ledger = Ledgers.get_ledger!(id)

    case Ledgers.update_ledger(ledger, ledger_params) do
      {:ok, ledger} ->
        conn
        |> put_flash(:info, "Ledger updated successfully.")
        |> redirect(to: ~p"/projects/#{ledger.project_id}")

      {:error, %Ecto.Changeset{} = changeset} ->
        project = Projects.get_project!(ledger.project_id)
        render(conn, :edit, ledger: ledger, changeset: changeset, project: project)
    end
  end

  def delete(conn, %{"id" => id}) do
    ledger = Ledgers.get_ledger!(id)
    {:ok, _ledger} = Ledgers.delete_ledger(ledger)

    conn
    |> put_flash(:info, "Ledger deleted successfully.")
    |> redirect(to: ~p"/projects/#{ledger.project_id}")
  end
end