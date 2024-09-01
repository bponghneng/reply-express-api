defmodule ReplyExpress.Application do
  # See https://hexdocs.pm/elixir/Application.html
  # for more information on OTP Applications
  @moduledoc false

  use Application

  @impl true
  def start(_type, _args) do
    children = [
      ReplyExpressWeb.Telemetry,
      ReplyExpress.Repo,
      # Commanded application
      ReplyExpress.Commanded,
      # Accounts projector
      ReplyExpress.Accounts.Supervisor,
      {DNSCluster, query: Application.get_env(:reply_express, :dns_cluster_query) || :ignore},
      {Phoenix.PubSub, name: ReplyExpress.PubSub},
      # Start the Finch HTTP client for sending emails
      {Finch, name: ReplyExpress.Finch},
      # Start a worker by calling: ReplyExpress.Worker.start_link(arg)
      # {ReplyExpress.Worker, arg},
      # Start to serve requests, typically the last entry
      ReplyExpressWeb.Endpoint
    ]

    # See https://hexdocs.pm/elixir/Supervisor.html
    # for other strategies and supported options
    opts = [strategy: :one_for_one, name: ReplyExpress.Supervisor]
    Supervisor.start_link(children, opts)
  end

  # Tell Phoenix to update the endpoint configuration
  # whenever the application is updated.
  @impl true
  def config_change(changed, _new, removed) do
    ReplyExpressWeb.Endpoint.config_change(changed, removed)
    :ok
  end
end
