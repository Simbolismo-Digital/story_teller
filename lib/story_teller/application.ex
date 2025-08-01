defmodule StoryTeller.Application do
  # See https://hexdocs.pm/elixir/Application.html
  # for more information on OTP Applications
  @moduledoc false

  use Application

  @impl true
  def start(_type, _args) do
    children = [
      StoryTellerWeb.Telemetry,
      StoryTeller.Repo,
      {DNSCluster, query: Application.get_env(:story_teller, :dns_cluster_query) || :ignore},
      {Phoenix.PubSub, name: StoryTeller.PubSub},
      # Start the Finch HTTP client for sending emails
      {Finch, name: StoryTeller.Finch},
      # Start a worker by calling: StoryTeller.Worker.start_link(arg)
      # {StoryTeller.Worker, arg},
      # Start to serve requests, typically the last entry
      StoryTellerWeb.Endpoint
    ]

    # See https://hexdocs.pm/elixir/Supervisor.html
    # for other strategies and supported options
    opts = [strategy: :one_for_one, name: StoryTeller.Supervisor]
    Supervisor.start_link(children, opts)
  end

  # Tell Phoenix to update the endpoint configuration
  # whenever the application is updated.
  @impl true
  def config_change(changed, _new, removed) do
    StoryTellerWeb.Endpoint.config_change(changed, removed)
    :ok
  end
end
