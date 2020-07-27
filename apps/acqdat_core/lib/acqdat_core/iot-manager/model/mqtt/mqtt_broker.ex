defmodule AcqdatCore.Model.IotManager.MQTTBroker do
  @moduledoc """
  Module exposes functions to work MQTT broker in IoT Manager App.
  """
  alias AcqdatCore.Model.IotManager.MQTT.Handler
  alias AcqdatCore.MQTT.Supervisor, as: MQTTSup
  alias AcqdatCore.Model.IotManager.MQTT.BrokerCredentials

  # TODO log error if client dosen't start for some reason
  def start_project_client(project_uuid, subscription_topics, password) do
    [host: host, port: port] = Application.get_env(:acqdat_core, :mqtt_broker)

    MQTTSup.start_child(
      client_id: project_uuid,
      handler: {Handler, []},
      server: {Tortoise.Transport.Tcp, host: host, port: String.to_integer(port)},
      subscriptions: subscription_topics,
      user_name: project_uuid,
      password: password
    )
  end

  def publish(client_id, topic, payload) do
    Tortoise.publish(
      client_id,
      topic,
      payload
    )
  end

  @doc """
  Starts subscriptions for all projects which have gateways using MQTT channel.
  """
  def start_children() do
    Task.start(fn ->
      clients = BrokerCredentials.broker_clients()

      Enum.each(clients, fn client ->
        start_project_client(client.entity_uuid, client.subscriptions, client.access_token)
      end)
    end)
  end
end
