defmodule CommonLedger.Application do
  # See https://hexdocs.pm/elixir/Application.html
  # for more information on OTP Applications
  @moduledoc false

  use Application

  @impl true
  def start(_type, _args) do
    children = [
      CommonLedgerWeb.Telemetry,
      CommonLedger.Repo,
      {DNSCluster, query: Application.get_env(:common_ledger, :dns_cluster_query) || :ignore},
      {Phoenix.PubSub, name: CommonLedger.PubSub},
      # Start the Finch HTTP client for sending emails
      {Finch, name: CommonLedger.Finch},
      # Start a worker by calling: CommonLedger.Worker.start_link(arg)
      # {CommonLedger.Worker, arg},
      # Start to serve requests, typically the last entry
      CommonLedgerWeb.Endpoint
    ]

    # See https://hexdocs.pm/elixir/Supervisor.html
    # for other strategies and supported options
    opts = [strategy: :one_for_one, name: CommonLedger.Supervisor]
    Supervisor.start_link(children, opts)
  end

  # Tell Phoenix to update the endpoint configuration
  # whenever the application is updated.
  @impl true
  def config_change(changed, _new, removed) do
    CommonLedgerWeb.Endpoint.config_change(changed, removed)
    :ok
  end
end
