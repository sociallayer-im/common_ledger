defmodule CommonLedger.Repo do
  use Ecto.Repo,
    otp_app: :common_ledger,
    adapter: Ecto.Adapters.Postgres
end
