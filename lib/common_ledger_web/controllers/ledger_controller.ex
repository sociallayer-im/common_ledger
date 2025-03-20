defmodule CommonLedgerWeb.LedgerController do
  use CommonLedgerWeb, :controller

  alias CommonLedger.Ledgers
  alias CommonLedger.Ledgers.Ledger
  alias CommonLedger.Projects

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

  def delete(conn, %{"id" => id}) do
    ledger = Ledgers.get_ledger!(id)
    {:ok, _ledger} = Ledgers.delete_ledger(ledger)

    conn
    |> put_flash(:info, "Ledger deleted successfully.")
    |> redirect(to: ~p"/projects/#{ledger.project_id}")
  end
end