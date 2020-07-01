defmodule AcqdatIot.DataParser do
  import Ecto.Query
  alias AcqdatCore.Schema.EntityManagement.GatewayDataDump, as: GDD
  alias AcqdatCore.Model.EntityManagement.Gateway, as: GModel
  alias AcqdatCore.Schema.EntityManagement.SensorsData, as: SData
  alias AcqdatCore.Schema.EntityManagement.GatewayData, as: GData
  alias AcqdatCore.Repo

  def extract_data() do
    data_dumps = Repo.all(GDD)
    Enum.each(data_dumps, fn data -> start_parsing(data) end)
  end

  def start_parsing(data_dump) do
    %{gateway_id: gateway_id, data: data} = data_dump
    mapped_parameters = fetch_mapped_parameters(gateway_id)
    [converted_data] = convert_data_to_key_value(data)
    parse_data(mapped_parameters, converted_data)
    # Repo.delete(data_dump)
  end

  defp fetch_mapped_parameters(gateway_id) do
    GModel.return_mapped_parameter(gateway_id)
  end

  defp parse_data(mapped_parameters, %{key: key, value: value}) when is_integer(value) do
    %{"entity" => entity, "entity_id" => entity_id, "value" => parameter_uuid} =
      mapped_parameters[key]

    send_data(entity, entity_id, parameter_uuid, value)
  end

  defp parse_data(mapped_parameters, %{key: key, value: value}) when is_list(value) do
    %{"value" => rules} = mapped_parameters[key]

    Enum.zip(rules, value)
    |> Enum.all?(fn {rule, value} ->
      %{"entity" => entity, "entity_id" => entity_id, "value" => parameter_uuid} = rule
      send_data(entity, entity_id, parameter_uuid, value)
    end)
  end

  defp parse_data(mapped_parameters, %{key: key, value: value}) when is_map(value) do
    %{"value" => rules} = mapped_parameters[key]
    Enum.zip(rules, value)
    |> Enum.all?(fn {{_key, rule}, {_key, value}} ->
      %{"entity" => entity, "entity_id" => entity_id, "value" => parameter_uuid} =
        extract_rule_data(rule)
      send_data(entity, entity_id, parameter_uuid, value)
    end)
  end

  defp convert_data_to_key_value(data) do
    for {key, value} <- data, do: %{key: key, value: value}
  end

  defp send_data(entity, entity_id, parameter_uuid, value) do
    case entity do
      "gateway" -> map_to_gateway(entity_id, parameter_uuid, value)
      "sensor" -> map_to_sensor(entity_id, parameter_uuid, value)
    end
  end

  defp map_to_sensor(entity_id, parameter_uuid, value) do
    query =
      from(sensor_data in SData,
        where: sensor_data.sensor_id == ^entity_id
      )
    sensor_datas = Repo.all(query)
    Enum.each(sensor_datas, fn sensor_data ->
      insert_sensor_data(sensor_data, parameter_uuid, value)
    end)
  end

  defp map_to_gateway(entity_id, parameter_uuid, value) do
    query =
      from(gateway_data in GData,
        where: gateway_data.gateway_id == ^entity_id
      )

    gateway_datas = Repo.all(query)

    Enum.each(gateway_datas, fn gateway_data ->
      insert_gateway_data(gateway_data, parameter_uuid, value)
    end)
  end

  defp insert_sensor_data(sensor_data, parameter_uuid, value) do
    %{parameters: parameters} = sensor_data
    parameters = prepare_parameters(parameters, parameter_uuid, value)
    changeset = SData.update_changeset(sensor_data, %{parameters: parameters})
    Repo.update(changeset)
  end

  defp insert_gateway_data(gateway_data, parameter_uuid, value) do
    %{parameters: parameters} = gateway_data
    parameters = prepare_parameters(parameters, parameter_uuid, value)
    changeset = GData.update_changeset(gateway_data, %{parameters: parameters})
    Repo.update(changeset)
  end

  defp prepare_parameters(parameters, parameter_uuid, value) do
    Enum.reduce(parameters, [], fn parameter, acc ->
      parameter = Map.from_struct(parameter)
      parameter =
        case parameter.uuid == parameter_uuid do
          true -> Map.replace!(parameter, :value, Integer.to_string(value))
          false -> parameter
        end

      acc = acc ++ [parameter]
    end)
  end

  defp extract_rule_data(%{"value" => value}) do
    %{"entity" => entity, "entity_id" => entity_id, "value" => parameter_uuid} = value
  end
end
