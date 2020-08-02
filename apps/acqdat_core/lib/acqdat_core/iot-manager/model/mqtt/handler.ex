defmodule AcqdatCore.Model.IotManager.MQTT.Handler do
  use Tortoise.Handler
  alias AcqdatCore.IotManager.DataDump.Worker.Server
  alias AcqdatCore.IotManager.CommandHandler
  alias AcqdatCore.Model.IotManager.MQTTBroker
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

  def handle_message([_org, org_uuid, _project, project_uuid, _gateway,
    gateway_uuid, "request-config"], _payload, state) do
      time = DateTime.utc_now() |> DateTime.to_unix()
      data = CommandHandler.get(gateway_uuid)
      data = if data do
        Map.put(data, :current_timestamp, time)
      else
        Map.put(%{}, :current_timestamp, time)
      end
    topic = "org/#{org_uuid}/project/#{project_uuid}/gateway/#{gateway_uuid}/config"
    MQTTBroker.publish(project_uuid, topic, Jason.encode!(data))

    {:ok, state}
  end

  def handle_message([_org, org_id, _project, project_id, _gateway,
    gateway_uuid], payload, state) do
    meta = %{org_uuid: org_id, project_uuid: project_id, gateway_uuid: gateway_uuid}
    log_data_if_valid(Jason.decode(payload), meta)
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
  defp log_data_if_valid({:ok, data}, meta) do
    params = Map.put(meta, :data, data)
    Server.create(params)
  end

  defp log_data_if_valid({:error, data}, _topic) do
    Logger.error("JSON parse error", addtitional: Map.from_struct(data))
  end
end
