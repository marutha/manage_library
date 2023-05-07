defmodule ManageLibrary.Application do
  # See https://hexdocs.pm/elixir/Application.html
  # for more information on OTP Applications
  @moduledoc false

  use Application

  @impl true
  def start(_type, _args) do
    children = [
      # Start the Telemetry supervisor
      ManageLibraryWeb.Telemetry,
      # Start the Ecto repository
      ManageLibrary.Repo,
      # Start the PubSub system
      {Phoenix.PubSub, name: ManageLibrary.PubSub},
      # Start Finch
      {Finch, name: ManageLibrary.Finch},
      # Start the Endpoint (http/https)
      ManageLibraryWeb.Endpoint
      # Start a worker by calling: ManageLibrary.Worker.start_link(arg)
      # {ManageLibrary.Worker, arg}
    ]

    # See https://hexdocs.pm/elixir/Supervisor.html
    # for other strategies and supported options
    opts = [strategy: :one_for_one, name: ManageLibrary.Supervisor]
    Supervisor.start_link(children, opts)
  end

  # Tell Phoenix to update the endpoint configuration
  # whenever the application is updated.
  @impl true
  def config_change(changed, _new, removed) do
    ManageLibraryWeb.Endpoint.config_change(changed, removed)
    :ok
  end
end
