defmodule Crytocurrencies.Application do
  # See https://hexdocs.pm/elixir/Application.html
  # for more information on OTP Applications
  @moduledoc false

  use Application

  @impl true
  def start(_type, _args) do
    children = [
      # Start the Telemetry supervisor
      CrytocurrenciesWeb.Telemetry,
      # Start the PubSub system
      {Phoenix.PubSub, name: Crytocurrencies.PubSub},
      # Start the Endpoint (http/https)
      CrytocurrenciesWeb.Endpoint
      # Start a worker by calling: Crytocurrencies.Worker.start_link(arg)
      # {Crytocurrencies.Worker, arg}
    ]

    # See https://hexdocs.pm/elixir/Supervisor.html
    # for other strategies and supported options
    opts = [strategy: :one_for_one, name: Crytocurrencies.Supervisor]
    Supervisor.start_link(children, opts)
  end

  # Tell Phoenix to update the endpoint configuration
  # whenever the application is updated.
  @impl true
  def config_change(changed, _new, removed) do
    CrytocurrenciesWeb.Endpoint.config_change(changed, removed)
    :ok
  end
end
