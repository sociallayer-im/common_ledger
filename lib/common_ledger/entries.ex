defmodule CommonLedger.Entries do
  import Ecto.Query
  alias CommonLedger.Repo
  alias CommonLedger.Entries.Entry
  
  def list_entries_by_ledger(ledger_id) do
    Repo.all(from e in Entry, where: e.ledger_id == ^ledger_id)
  end

  def get_entry!(id), do: Repo.get!(Entry, id)
  
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
end