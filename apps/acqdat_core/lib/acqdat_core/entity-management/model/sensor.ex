defmodule AcqdatCore.Model.EntityManagement.Sensor do
  alias AcqdatCore.Schema.EntityManagement.{Sensor, SensorsData, SensorType}
  alias AcqdatCore.Domain.EntityManagement.SensorData, as: SensorDataDomain
  alias AcqdatCore.Repo
  alias AcqdatCore.ElasticSearch
  alias AcqdatCore.Model.Helper, as: ModelHelper
  alias Elixlsx.{Workbook, Sheet}
  alias AcqdatCore.Model.IotManager.Gateway
  import Ecto.Query

  def create(params) do
    changeset = Sensor.changeset(%Sensor{}, params)

    case Repo.insert(changeset) do
      {:ok, sensor} ->
        Task.start_link(fn ->
          ElasticSearch.insert_sensor("sensors", sensor)
        end)

        {:ok, sensor}

      {:error, message} ->
        {:error, message}
    end
  end

  def return_count(%{"type" => "Sensor", "project_id" => project_id}) do
    query =
      from(p in Sensor,
        where: p.project_id == ^project_id,
        select: count(p.id)
      )

    Repo.one(query)
  end

  def return_count(%{"type" => "Sensor"}) do
    query =
      from(p in Sensor,
        select: count(p.id)
      )

    Repo.one(query)
  end

  def update(sensor, params) do
    changeset = Sensor.update_changeset(sensor, params)

    case Repo.update(changeset) do
      {:ok, sensor} ->
        Task.start_link(fn ->
          ElasticSearch.insert_sensor("sensors", sensor)
        end)

        {:ok, sensor}

      {:error, message} ->
        {:error, message}
    end
  end

  def get_for_view(sensor_ids) do
    query =
      from(sensor in Sensor,
        where: sensor.id in ^sensor_ids,
        preload: [:sensor_type],
        order_by: [desc: :inserted_at]
      )

    Repo.all(query)
  end

  def get(id) when is_integer(id) do
    case Repo.get(Sensor, id) do
      nil ->
        {:error, "not found"}

      sensor ->
        sensor = Repo.preload(sensor, [:sensor_type])
        {:ok, sensor}
    end
  end

  def remove_sensor(sensor_ids) do
    query =
      from(sensor in Sensor,
        where: sensor.id in ^sensor_ids
      )

    Repo.update_all(query, set: [gateway_id: nil])
  end

  def add_sensor(sensor_ids, gateway) do
    query =
      from(sensor in Sensor,
        where: sensor.id in ^sensor_ids
      )

    Repo.update_all(query, set: [gateway_id: gateway.id])
  end

  def get(query) when is_map(query) do
    case Repo.get_by(Sensor, query) do
      nil ->
        {:error, "not found"}

      sensor ->
        {:ok, sensor}
    end
  end

  def get_all_by_sensor_type(entity_ids) do
    Sensor
    |> where([sensor], sensor.sensor_type_id in ^entity_ids)
    |> order_by(:id)
    |> Repo.all()
  end

  def get_all_by_parent_gateway(gateway_ids) do
    Sensor
    |> where([sensor], sensor.gateway_id in ^gateway_ids)
    |> preload([:sensor_type])
    |> Repo.all()
  end

  def get_all_by_parent_project(project_id) do
    Sensor
    |> where([sensor], sensor.project_id == ^project_id)
    |> where([sensor], sensor.parent_type == "Project")
    |> preload([:sensor_type])
    |> Repo.all()
  end

  def get_all(%{page_size: page_size, page_number: page_number}) do
    Sensor |> order_by(:id) |> Repo.paginate(page: page_number, page_size: page_size)
  end

  def get_all(%{page_size: page_size, page_number: page_number}, preloads) do
    paginated_sensor_data =
      Sensor |> order_by(:id) |> Repo.paginate(page: page_number, page_size: page_size)

    sensor_data_with_preloads = paginated_sensor_data.entries |> Repo.preload(preloads)

    ModelHelper.paginated_response(sensor_data_with_preloads, paginated_sensor_data)
  end

  def get_all_by_project_n_org(%{
        page_size: page_size,
        page_number: page_number,
        project_id: project_id,
        org_id: org_id
      }) do
    paginated_sensor_data =
      Sensor
      |> where([sensor], sensor.project_id == ^project_id)
      |> where([sensor], sensor.org_id == ^org_id)
      |> order_by(:id)
      |> Repo.paginate(page: page_number, page_size: page_size)

    sensor_data_with_preloads = paginated_sensor_data.entries |> Repo.preload([:sensor_type])

    ModelHelper.paginated_response(sensor_data_with_preloads, paginated_sensor_data)
  end

  def get_all_by_device(device_id) do
    query =
      from(sensor in Sensor,
        where: sensor.device_id == ^device_id,
        select: sensor
      )

    Repo.all(query)
  end

  def get_all_by_criteria(id, preloads) when is_integer(id) do
    query =
      from(sensor in Sensor,
        where: sensor.device_id == ^id,
        select: sensor
      )

    Repo.all(query) |> Repo.preload(preloads)
  end

  def get_all_by_sensor_type(sensor_type_id) do
    from(sensor in Sensor,
      where: sensor.sensor_type_id == ^sensor_type_id,
      select: map(sensor, [:id, :name])
    )
    |> Repo.all()
  end

  def child_sensors_query(root) when not is_list(root) do
    from(sensor in Sensor,
      preload: [:sensor_type, :gateway],
      where: sensor.parent_id == ^root.id and sensor.parent_type == "Asset"
    )
  end

  def child_sensors(root, sensor_type_ids) when not is_list(root) do
    from(sensor in Sensor,
      preload: [:sensor_type],
      where:
        sensor.parent_id == ^root.id and sensor.parent_type == "Asset" and
          sensor.sensor_type_id in ^sensor_type_ids
    )
    |> Repo.all()
  end

  def child_sensors_query(asset_ids) when is_list(asset_ids) do
    from(sensor in Sensor,
      preload: [:sensor_type],
      where: sensor.parent_id in ^asset_ids and sensor.parent_type == "Asset"
    )
  end

  def child_sensors(root) do
    child_sensors_query(root)
    |> Repo.all()
  end

  def get_all() do
    Repo.all(Sensor)
  end

  def delete(sensor_id) do
    sensor = Repo.get(Sensor, sensor_id)

    if has_iot_data?(sensor.id, sensor.project_id) do
      {:error, "It contains time-series data. Please delete sensors data before deleting sensor."}
    else
      case Repo.delete(sensor) do
        {:ok, sensor} ->
          Task.start_link(fn ->
            ElasticSearch.delete("sensors", sensor.id)
          end)

          {:ok, sensor |> Repo.preload(:sensor_type)}

        {:error, message} ->
          {:error, message}
      end
    end
  end

  def fetch_sensor_by_parameters(%{
        "entities" => entities,
        "date_from" => date_from,
        "date_to" => date_to
      }) do
    [input_params, param_uuids, sensor_ids] =
      Enum.reduce(entities, [[], [], []], fn param, [acc1, acc2, acc3] ->
        [
          ["#{param["sensor_id"]}_#{param["param_uuid"]}" | acc1],
          [param["param_uuid"] | acc2],
          [param["sensor_id"] | acc3]
        ]
      end)

    date_from = from_unix(date_from)
    date_to = from_unix(date_to)

    input_params = Enum.uniq(input_params)
    param_uuids = Enum.uniq(param_uuids)
    sensor_ids = Enum.uniq(sensor_ids)

    sensors =
      from(
        sensor in Sensor,
        join: sensor_type in SensorType,
        on: sensor.sensor_type_id == sensor_type.id,
        cross_join: c in fragment("unnest(?)", sensor_type.parameters),
        where: sensor.id in ^sensor_ids and fragment("?->>'uuid'", c) in ^param_uuids,
        select: %{
          sensor_id: sensor.id,
          sensor_name: sensor.name,
          gateway_id: sensor.gateway_id,
          param_name: fragment("?->>'name'", c),
          param_uuid: fragment("?->>'uuid'", c)
        }
      )
      |> Repo.all()

    data_grouped_by_gateway = Enum.group_by(sensors, fn sensor -> sensor.gateway_id end)

    gateway_ids = Map.keys(data_grouped_by_gateway)

    gateway_data = Gateway.get_names_by_ids(gateway_ids)

    workbook = {:ok, %Workbook{}}

    output =
      Enum.reduce(data_grouped_by_gateway, workbook, fn {gateway_id, value}, acc ->
        {:ok, workbook} = acc

        [header_uuids, header_names] =
          Enum.reduce(value, [[], []], fn entity, [header_uuids, header_names] ->
            if Enum.member?(input_params, "#{entity.sensor_id}_#{entity.param_uuid}") do
              [
                ["#{entity.sensor_id}_#{entity.param_uuid}" | header_uuids],
                ["#{entity.sensor_name} #{entity.param_name}" | header_names]
              ]
            else
              [header_uuids, header_names]
            end
          end)

        header_uuids = Enum.uniq(header_uuids)
        header_names = Enum.uniq(header_names)

        [%{name: gateway_name}] = Enum.filter(gateway_data, fn data -> data.id == gateway_id end)

        trans =
          Repo.transaction(
            fn ->
              SensorDataDomain.filter_by_date_query_wrt_format(sensor_ids, date_from, date_to)
              |> Repo.stream(max_rows: 1000)
              |> Stream.map(fn grouped_data ->
                [timestamp, sensor_data] = grouped_data
                rows_len = length(header_uuids)

                empty_row = List.duplicate(nil, rows_len)

                res =
                  Enum.reduce(sensor_data, [], fn {sensor_id, params}, acc ->
                    res =
                      Enum.reduce(params, empty_row, fn param, acc1 ->
                        indx_pos =
                          Enum.find_index(header_uuids, fn x ->
                            x == "#{sensor_id}_#{param["uuid"]}"
                          end)

                        if indx_pos != nil,
                          do: List.replace_at(acc1, indx_pos, param["value"]),
                          else: acc1
                      end)
                  end)

                res =
                  if res != empty_row do
                    ["#{timestamp}" | res]
                  end

                res
              end)
              |> Enum.filter(&(!is_nil(&1)))
              |> Enum.to_list()
              |> gen_xls_sheet(header_names, gateway_name, workbook)
            end,
            timeout: :infinity
          )

        trans
      end)
      |> write_to_xls()
  end

  def gen_xls_sheet(data, headers, gateway_name, workbook) do
    headers = ["#{gateway_name} timestamp" | headers]

    sheet = %Sheet{name: "GatewayData of #{gateway_name}", rows: [headers] ++ data}

    Workbook.append_sheet(workbook, sheet)
  end

  def write_to_xls({:ok, workbook}) do
    path =
      Application.app_dir(
        :acqdat_api,
        "priv/static/reports/gateways/report_#{String.slice(UUID.uuid1(:hex), 0..6)}.xlsx"
      )

    workbook |> Elixlsx.write_to(path)

    path
  end

  defp has_iot_data?(sensor_id, project_id) do
    query =
      from(
        data in SensorsData,
        where: data.sensor_id == ^sensor_id and data.project_id == ^project_id
      )

    Repo.exists?(query)
  end

  defp from_unix(datetime) do
    {datetime, _} = Integer.parse(datetime)
    {:ok, res} = datetime |> DateTime.from_unix(:millisecond)
    res
  end
end
