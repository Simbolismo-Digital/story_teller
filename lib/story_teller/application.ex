defmodule StoryTeller.Application do
  # See https://hexdocs.pm/elixir/Application.html
  # for more information on OTP Applications
  @moduledoc false

  use Application

  @impl true
  def start(_type, _args) do
    children =
      [
        StoryTellerWeb.Telemetry,
        StoryTeller.Repo,
        {DNSCluster, query: Application.get_env(:story_teller, :dns_cluster_query) || :ignore},
        {Phoenix.PubSub, name: StoryTeller.PubSub},
        # Start the Finch HTTP client for sending emails
        {Finch, name: StoryTeller.Finch},
        StoryTeller.Llm.GeminiLimiter,
        # Start a worker by calling: StoryTeller.Worker.start_link(arg)
        # {StoryTeller.Worker, arg},
        # Start to serve requests, typically the last entry
        StoryTellerWeb.Endpoint,
        {Registry, keys: :unique, name: StoryTeller.Player.Registry}
      ] ++ application_children()

    # See https://hexdocs.pm/elixir/Supervisor.html
    # for other strategies and supported options
    opts = [strategy: :one_for_one, name: StoryTeller.Supervisor]
    Supervisor.start_link(children, opts)
  end

  def application_children do
    # Only enable music if running iex -S hooked
    application_children(not List.ends_with?(:escript.script_name(), ~c"mix"))
  end

  def application_children(false = _iex), do: []

  def application_children(true = _iex),
    do:
      [StoryTeller.God] ++
        List.wrap(Application.get_env(:story_teller, StoryTeller.Music)[:player])

  # Tell Phoenix to update the endpoint configuration
  # whenever the application is updated.
  @impl true
  def config_change(changed, _new, removed) do
    StoryTellerWeb.Endpoint.config_change(changed, removed)
    :ok
  end
end
