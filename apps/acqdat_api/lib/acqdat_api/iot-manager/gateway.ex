defmodule AcqdatApi.IotManager.Gateway do
  import AcqdatApiWeb.Helpers
  alias AcqdatCore.Repo
  alias AcqdatCore.Model.IotManager.Gateway
  alias AcqdatCore.IotManager.CommandHandler

  defdelegate get_all(data, preloads), to: Gateway
  defdelegate get_by_org(org_id), to: Gateway
  defdelegate delete(gateway), to: Gateway
  defdelegate associate_sensors(gateway, sensor_ids), to: Gateway

  def create(params) do
    params = params_extraction(params)
    Gateway.create(params) |> verify_gateway()
  end

  def update(gateway, params) do
    gateway |> Gateway.update(params) |> verify_gateway()
  end

  def load_associations(gateway) do
    Repo.preload(gateway, [:org, :project, :sensors])
  end

  def setup_config(gateway, _channel = "http", params) do
    %{"commands" => command} = params
    CommandHandler.put(gateway.uuid, command)
  end

  def setup_config(gateway, _channel = "mqtt", params) do
    %{"commands" => command} = params
    CommandHandler.put(gateway.uuid, command)
    Gateway.send_mqtt_config(gateway, command)
  end

  def preload_sensor(gateway) do
    gateway |> Repo.preload(:sensors)
  end

  def tree_mapping(nil) do
    nil
  end

  def tree_mapping(mapped_parameters) do
    Enum.reduce(mapped_parameters, %{}, fn {key, value}, acc ->
      return_uuid_and_parameter_name(key, value, acc)
    end)
  end

  defp return_uuid_and_parameter_name(key, %{type: "value", value: value}, acc) do
    Map.put_new(acc, to_string(value), to_string(key))
  end

  defp return_uuid_and_parameter_name(key, %{type: "object", value: value} = object_value, acc) do
    key = to_string(key)
    keys = Map.keys(value)
    for k <- keys do
      sk = "#{key}." <> to_string(k)
      return_uuid_and_parameter_name(sk, Map.fetch!(value, k), acc)
    end
  end

  # defp return_uuid_and_parameter_name(key, %{type: "list", value: value} = list_value, acc) do
  #   key = to_string(key)
  #   list_of_value =
  #   for k <- value do
  #     return_uuid_and_parameter_name(key, k, acc)
  #   end
  #   traverse_and_return_correct_accumulator(list_of_value, acc)
  # end


  ############################# private functions ###############3

  defp verify_gateway({:ok, gateway}) do
    gateway = gateway |> Repo.preload([:org, :project, :sensors])
    {:ok, gateway}
  end

  defp verify_gateway({:error, gateway}) do
    {:error, %{error: extract_changeset_error(gateway)}}
  end

  defp params_extraction(params) do
    Map.from_struct(params)
    |> Map.drop([:_id, :__meta__])
  end
end
