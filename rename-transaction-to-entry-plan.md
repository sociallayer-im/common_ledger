# Rename Transaction to Entry

## Steps

1. Create a new migration to rename the table:
```elixir
rename table(:transactions), to: table(:entries)
```

2. Move and rename the files:
- Move `lib/common_ledger/transactions/transaction.ex` to `lib/common_ledger/entries/entry.ex`
- Create `lib/common_ledger/entries.ex` context module

3. Update the Entry schema:
- Rename module from `Transaction` to `Entry`
- Update schema name from "transactions" to "entries"

4. Update references in other files:
- Update ledger.ex to reference entries instead of transactions
- Update any migration files that reference transactions
- Update any context modules that reference transactions

5. Update any existing migrations that haven't been run yet to use the new name

## Implementation Details

The Entry schema will maintain the same fields but with renamed associations:
```elixir
schema "entries" do
  field :amount, :decimal
  field :currency, :string
  field :description, :string
  
  belongs_to :ledger, Ledger

  timestamps()
end
```

The Entries context will provide the same functionality but with renamed functions:
```elixir
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
```