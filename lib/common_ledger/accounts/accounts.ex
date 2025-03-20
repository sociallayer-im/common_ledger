defmodule CommonLedger.Accounts.Accounts do
  import Ecto.Query
  alias CommonLedger.Repo
  alias CommonLedger.Accounts.Account

  def list_accounts_by_project(project_id) do
    Repo.all(from a in Account, where: a.project_id == ^project_id)
  end

  def get_account!(id), do: Repo.get!(Account, id)

  def create_account(attrs \\ %{}) do
    %Account{}
    |> Account.changeset(attrs)
    |> Repo.insert()
  end

  def update_account(%Account{} = account, attrs) do
    account
    |> Account.changeset(attrs)
    |> Repo.update()
  end

  def delete_account(%Account{} = account) do
    Repo.delete(account)
  end

  def change_account(%Account{} = account, attrs \\ %{}) do
    Account.changeset(account, attrs)
  end
end