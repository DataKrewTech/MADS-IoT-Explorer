defmodule AcqdatCore.Model.IotManager.MQTT.Handler do
  use Tortoise.Handler
  alias AcqdatCore.IotManager.DataDump.Worker.Server
  require Logger

  def init(args) do
    {:ok, args}
  end

  # TODO mqtt broker status updates need to be logged carefully
  def connection(status, state) do
    # `status` will be either `:up` or `:down`; you can use this to
    # inform the rest of your system if the connection is currently
    # open or closed; tortoise should be busy reconnecting if you get
    # a `:down`
    if status == :down do
      Logger.warn("mqtt connection down")
    else
      Logger.info("mqtt connected")
    end

    {:ok, state}
  end

  def handle_message(topic, payload, state) do
    log_data_if_valid(Jason.decode(payload), topic)
    {:ok, state}
  end

  def subscription(_status, _topic_filter, state) do
    {:ok, state}
  end

  def terminate(_reason, _state) do
    # tortoise doesn't care about what you return from terminate/2,
    # that is in alignment with other behaviours that implement a
    # terminate-callback
    :ok
  end

  ######################## private functions ######################

  # TODO: At present data being received is not enriched and needs the client
  # to send data in our format inspite of providing mapped parameters support
  # we need to modify this so gateway_id doesn't need to be part of the json
  # being sent both for MQTT as well as HTTP.
  defp log_data_if_valid({:ok, data}, _topic) do
    Server.create(data)
  end

  defp log_data_if_valid({:error, data}, _topic) do
    Logger.error("JSON parse error", addtitional: Map.from_struct(data))
  end
end
