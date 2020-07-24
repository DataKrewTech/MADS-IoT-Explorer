defmodule AcqdatCore.Model.IotManager.MQTT.Handler do
  use Tortoise.Handler
  require Logger

  def init(args) do
    {:ok, args}
  end

  def connection(_status, state) do
    # `status` will be either `:up` or `:down`; you can use this to
    # inform the rest of your system if the connection is currently
    # open or closed; tortoise should be busy reconnecting if you get
    # a `:down`
    {:ok, state}
  end

  def handle_message(_topic, payload, state) do
    log_data_if_valid(Jason.decode(payload))

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
  defp log_data_if_valid({:ok, data}) do
    require IEx
    IEx.pry
  end

  defp log_data_if_valid({:error, data}) do
    Logger.error("JSON parse error", [addtitional: Map.from_struct(data)])
  end
end
