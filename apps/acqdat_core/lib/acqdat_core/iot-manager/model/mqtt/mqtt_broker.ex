defmodule AcqdatCore.Model.IotManager.MQTTBroker do
  @moduledoc """
  Module exposes functions to work MQTT broker in IoT Manager App.
  """
  alias AcqdatCore.Model.IotManager.MQTT.Handler

  def start_project_client(project_id, subscription_topics, password) do
    Tortoise.Supervisor.start_child(
      client_id: project_id,
      handler: Handler,
      server: {Tortoise.Transport.Tcp, host: 'localhost', port: 1883},
      subsriptions: subscription_topics,
      username: project_id,
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

end
