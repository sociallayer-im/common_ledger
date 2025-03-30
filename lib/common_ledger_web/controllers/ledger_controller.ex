defmodule CommonLedgerWeb.LedgerController do
  use CommonLedgerWeb, :controller

  alias CommonLedger.Ledgers
  alias CommonLedger.Ledgers.Ledger
  alias CommonLedger.Projects
  alias CommonLedger.Entries
  alias CommonLedgerWeb.AuthHelper

  def new(conn, %{"project_id" => project_id}) do
    case AuthHelper.ensure_project_member(conn, project_id) do
      {:ok, conn} ->
        project = Projects.get_project!(project_id)
        changeset = Ledger.changeset(%Ledger{project_id: project_id}, %{})
        render(conn, :new, changeset: changeset, project: project)

      {:error, :unauthorized} ->
        conn
        |> put_flash(:error, "You must be a project member to create ledgers")
        |> redirect(to: ~p"/projects/#{project_id}")
    end
  end

  def create(conn, %{"project_id" => project_id, "ledger" => ledger_params}) do
    case AuthHelper.ensure_project_member(conn, project_id) do
      {:ok, conn} ->
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

      {:error, :unauthorized} ->
        conn
        |> put_flash(:error, "You must be a project member to create ledgers")
        |> redirect(to: ~p"/projects/#{project_id}")
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

  def export(conn, %{"id" => id}) do
    ledger = Ledgers.get_ledger!(id)
    entries = Entries.list_entries_by_ledger(id)

    csv_content =
      ([["Amount", "Currency", "Category", "Description", "Account", "Memo", "Date"]] ++
         Enum.map(entries, fn entry ->
           [
             entry.amount,
             entry.currency,
             entry.category || "",
             entry.description || "",
             if(entry.account, do: entry.account.name, else: ""),
             entry.memo || "",
             NaiveDateTime.to_string(entry.inserted_at)
           ]
         end))
      |> CSV.encode()
      |> Enum.to_list()
      |> Enum.join()

    conn
    |> put_resp_content_type("text/csv")
    |> put_resp_header("content-disposition", "attachment; filename=#{ledger.name}_entries.csv")
    |> send_resp(200, csv_content)
  end
end
