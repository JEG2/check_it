defmodule CheckIt.Application do
  # See https://hexdocs.pm/elixir/Application.html
  # for more information on OTP Applications
  @moduledoc false

  use Application

  @impl true
  def start(_type, _args) do
    children = [
      CheckItWeb.Telemetry,
      CheckIt.Repo,
      {DNSCluster, query: Application.get_env(:check_it, :dns_cluster_query) || :ignore},
      {Phoenix.PubSub, name: CheckIt.PubSub},
      # Start the Finch HTTP client for sending emails
      {Finch, name: CheckIt.Finch},
      # Start a worker by calling: CheckIt.Worker.start_link(arg)
      # {CheckIt.Worker, arg},
      {Agent, &init_db/0},
      # Start to serve requests, typically the last entry
      CheckItWeb.Endpoint
    ]

    # See https://hexdocs.pm/elixir/Supervisor.html
    # for other strategies and supported options
    opts = [strategy: :one_for_one, name: CheckIt.Supervisor]
    Supervisor.start_link(children, opts)
  end

  # Tell Phoenix to update the endpoint configuration
  # whenever the application is updated.
  @impl true
  def config_change(changed, _new, removed) do
    CheckItWeb.Endpoint.config_change(changed, removed)
    :ok
  end

  def init_db do
    :ets.new(:lists, [:public, :named_table])
    :ets.new(:items, [:public, :named_table])
  end
end
