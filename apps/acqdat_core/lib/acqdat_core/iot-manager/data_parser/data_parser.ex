defmodule AcqdatCore.IotManager.DataParser do
  alias AcqdatCore.Model.IotManager.Gateway, as: GModel
  alias AcqdatCore.Repo
  alias AcqdatCore.Schema.EntityManagement.GatewayData, as: GDSchema
  alias AcqdatCore.Schema.EntityManagement.SensorsData, as: SDSchema
  alias AcqdatCore.Schema.EntityManagement.GatewayData.Parameters, as: GParam
  alias AcqdatCore.Schema.EntityManagement.SensorsData.Parameters, as: SParam
  alias AcqdatCore.Model.EntityManagement.Sensor, as: SModel

  def start_parsing(data_dump) do
    %{gateway_id: gateway_id, data: iot_data} = data_dump
    mapped_parameters = fetch_mapped_parameters(gateway_id)

    iot_data
    |> Enum.reduce(%{}, fn {key, value}, acc ->
      if mapped_parameters[key]["type"] == "value" do
        parse_data(mapped_parameters[key], value, acc)
      else
        key_mapped_parameters = mapped_parameters[key]["value"]
        parse_data(key_mapped_parameters, value, acc)
      end
    end)
    |> persist_data(data_dump.org_id, data_dump.project_id)
  end

  ######### persist data private helpers #############

  defp persist_data(iot_data, org_id, project_id) do
    Enum.map(iot_data, fn {key, data} ->
      data_manifest(key, data, org_id, project_id)
    end)
  end

  defp data_manifest(:gateway_data, data, org_id, project_id) do
    gateway_data =
      Enum.reduce(data, [], fn {key, parameters}, acc ->
        params = %{
          gateway_id: key,
          org_id: org_id,
          project_id: project_id,
          parameters: parameters,
          inserted_timestamp: DateTime.truncate(DateTime.utc_now(), :second),
          inserted_at: DateTime.truncate(DateTime.utc_now(), :second)
        }

        parameters = prepare_gateway_parameters(parameters)
        params = Map.replace!(params, :parameters, parameters)
        acc ++ [params]
      end)

    Repo.insert_all(GDSchema, gateway_data)
  end

  defp data_manifest(:sensor_data, data, org_id, project_id) do
    sensor_data =
      Enum.reduce(data, [], fn {key, parameters}, acc ->
        params = %{
          sensor_id: key,
          org_id: org_id,
          project_id: project_id,
          parameters: parameters,
          inserted_timestamp: DateTime.truncate(DateTime.utc_now(), :second),
          inserted_at: DateTime.truncate(DateTime.utc_now(), :second)
        }

        parameters = prepare_sensor_parameters(parameters)
        params = Map.replace!(params, :parameters, parameters)
        acc ++ [params]
      end)

    Repo.insert_all(SDSchema, sensor_data)
  end

  ##################### parsing data private helpers ###################

  defp prepare_gateway_parameters(parameters) do
    Enum.reduce(parameters, [], fn param, acc ->
      acc ++ [struct!(GParam, param)]
    end)
  end

  defp prepare_sensor_parameters(parameters) do
    Enum.reduce(parameters, [], fn param, acc ->
      acc ++ [struct!(SParam, param)]
    end)
  end

  defp fetch_mapped_parameters(gateway_id) do
    GModel.return_mapped_parameter(gateway_id)
  end

  defp parse_data(mapped_parameters, value, acc) when is_list(value) do
    mapped_parameters
    |> Enum.zip(value)
    |> Enum.reduce(acc, fn {rule, value}, acc ->
      %{"entity" => entity, "entity_id" => entity_id, "value" => parameter_uuid} = rule
      create_data_struct(entity, entity_id, parameter_uuid, value, acc)
    end)
  end

  defp parse_data(mapped_parameters, value, acc) when is_map(value) do
    Enum.reduce(value, acc, fn {key, value}, acc ->
      if mapped_parameters[key]["type"] == "value" do
        parse_data(mapped_parameters[key], value, acc)
      else
        key_mapped_parameters = mapped_parameters[key]["value"]
        parse_data(key_mapped_parameters, value, acc)
      end
    end)
  end

  defp parse_data(mapped_parameters, value, acc) do
    %{"entity" => entity, "entity_id" => entity_id, "value" => parameter_uuid} = mapped_parameters

    create_data_struct(entity, entity_id, parameter_uuid, value, acc)
  end

  defp create_data_struct("sensor", entity_id, parameter_uuid, value, acc) do
    parameter = get_parameter_attributes("sensor", entity_id, parameter_uuid)

    value = %{
      name: parameter.name,
      data_type: parameter.data_type,
      uuid: parameter_uuid,
      value: value
    }

    acc = Map.put_new(acc, :sensor_data, %{})

    value =
      Map.put(acc[:sensor_data], entity_id, collate_value(acc[:sensor_data], entity_id, value))

    Map.put(acc, :sensor_data, value)
  end

  defp create_data_struct("gateway", entity_id, parameter_uuid, value, acc) do
    parameter = get_parameter_attributes("gateway", entity_id, parameter_uuid)

    value = %{
      name: parameter.name,
      data_type: parameter.data_type,
      uuid: parameter_uuid,
      value: value
    }

    acc = Map.put_new(acc, :gateway_data, %{})

    value =
      Map.put(acc[:gateway_data], entity_id, collate_value(acc[:gateway_data], entity_id, value))

    Map.put(acc, :gateway_data, value)
  end

  def collate_value(acc, key, value) do
    if acc[key] do
      [value | acc[key]]
    else
      [value]
    end
  end

  defp get_parameter_attributes("sensor", entity_id, parameter_uuid) do
    {:ok, sensor} = SModel.get(entity_id)
    # here one check needs to be put incase result is returned to he an empty list
    [result] =
      Enum.filter(sensor.sensor_type.parameters, fn parameter ->
        parameter.uuid == parameter_uuid
      end)

    result
  end

  defp get_parameter_attributes("gateway", entity_id, parameter_uuid) do
    {:ok, gateway} = GModel.get_by_id(entity_id)

    [result] =
      Enum.filter(gateway.streaming_data, fn parameter ->
        parameter.uuid == parameter_uuid
      end)

    result
  end
end
