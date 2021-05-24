defmodule AcqdatCore.Model.EntityManagement.Sensor do
  alias AcqdatCore.Schema.EntityManagement.{Sensor, SensorsData}
  alias AcqdatCore.Repo
  alias AcqdatCore.ElasticSearch
  alias AcqdatCore.Model.Helper, as: ModelHelper
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

  def return_count(%{"project_id" => project_id}) do
    query =
      from(p in Sensor,
        where: p.project_id == ^project_id,
        select: count(p.id)
      )

    Repo.one(query)
  end

  def return_count("Sensor") do

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

  defp has_iot_data?(sensor_id, project_id) do
    query =
      from(
        data in SensorsData,
        where: data.sensor_id == ^sensor_id and data.project_id == ^project_id
      )

    Repo.exists?(query)
  end
end
