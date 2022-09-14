defmodule LiveBabiniku.Application do
  # See https://hexdocs.pm/elixir/Application.html
  # for more information on OTP Applications
  @moduledoc false

  use Application

  @impl true
  def start(_type, _args) do
    children = [
      LiveBabiniku.PromEx,
      # Start the Telemetry supervisor
      LiveBabinikuWeb.Telemetry,
      # Start the PubSub system
      {Phoenix.PubSub, name: LiveBabiniku.PubSub},
      # Start the Endpoint (http/https)
      LiveBabinikuWeb.Endpoint,
      # Start a worker by calling: LiveBabiniku.Worker.start_link(arg)
      # {LiveBabiniku.Worker, arg}
      {LiveBabiniku.Tracker, pubsub_server: LiveBabiniku.PubSub},
      {DynamicSupervisor, name: LiveBabiniku.RoomSupervisor, strategy: :one_for_one}
    ]

    # See https://hexdocs.pm/elixir/Supervisor.html
    # for other strategies and supported options
    opts = [strategy: :one_for_one, name: LiveBabiniku.Supervisor]
    Supervisor.start_link(children, opts)
  end

  # Tell Phoenix to update the endpoint configuration
  # whenever the application is updated.
  @impl true
  def config_change(changed, _new, removed) do
    LiveBabinikuWeb.Endpoint.config_change(changed, removed)
    :ok
  end
end
