defmodule CommonLedger.Ledgers do
  import Ecto.Query
  alias CommonLedger.Repo
  alias CommonLedger.Ledgers.Ledger

  def list_ledgers_by_team(team_id) do
    Repo.all(from l in Ledger, where: l.team_id == ^team_id)
  end

  def get_ledger!(id), do: Repo.get!(Ledger, id)

  def create_ledger(attrs \\ %{}) do
    %Ledger{}
    |> Ledger.changeset(attrs)
    |> Repo.insert()
  end

  def update_ledger(%Ledger{} = ledger, attrs) do
    ledger
    |> Ledger.changeset(attrs)
    |> Repo.update()
  end

  def delete_ledger(%Ledger{} = ledger) do
    Repo.delete(ledger)
  end

  def get_ledger_with_transactions!(id) do
    Repo.get!(Ledger, id)
    |> Repo.preload(:transactions)
  end
end