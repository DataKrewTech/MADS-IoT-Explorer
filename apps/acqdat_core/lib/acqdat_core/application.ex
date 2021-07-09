defmodule AcqdatCore.Application do
  # See https://hexdocs.pm/elixir/Application.html
  # for more information on OTP Applications
  @moduledoc false

  use Application
  alias AcqdatCore.Model.IotManager.MQTTBroker

  def start(_, _) do
    children = [
      # Start the Ecto repository
      AcqdatCore.Repo,
      AcqdatCore.IotManager.CommandHandler,
      AcqdatCore.IotManager.DataParser.Supervisor,
      AcqdatCore.IotManager.DataDump.Supervisor,
      {AcqdatCore.MQTT.Supervisor, strategy: :one_for_one},
      AcqdatCore.Domain.Notification.Supervisor,
      AcqdatCore.Alerts.Supervisor
    ]

    # See https://hexdocs.pm/elixir/Supervisor.html
    # for other strategies and supported options
    opts = [strategy: :one_for_one, name: AcqdatCore.Supervisor]
    result = Supervisor.start_link(children, opts)
    initialize()
    result
  end

  # Initializes components that need to be started after application is up.
  # Make Sure all the initializers are asynchronous in nature so they don't
  # block the application startup.
  defp initialize() do
    MQTTBroker.start_children()
  end
end
