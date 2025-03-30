defmodule CommonLedger.Entries do
  import Ecto.Query
  alias CommonLedger.Repo
  alias CommonLedger.Entries.Entry

  def list_entries_by_ledger(ledger_id) do
    Entry
    |> where([e], e.ledger_id == ^ledger_id)
    |> preload(:account)
    |> Repo.all()
  end

  def get_entry!(id), do: Repo.get!(Entry, id) |> Repo.preload(:account)

  def create_entry(attrs \\ %{}) do
    %Entry{}
    |> Entry.changeset(attrs)
    |> Repo.insert()
  end

  def update_entry(%Entry{} = entry, attrs) do
    entry
    |> Entry.changeset(attrs)
    |> Repo.update()
  end

  def delete_entry(%Entry{} = entry) do
    Repo.delete(entry)
  end

  def change_entry(%Entry{} = entry, attrs \\ %{}) do
    Entry.changeset(entry, attrs)
  end
end
