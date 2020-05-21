defmodule AcqdatCore.Model.EntityManagement.Sensor do
  alias AcqdatCore.Schema.EntityManagement.{Sensor, SensorData}
  alias AcqdatCore.Repo
  alias AcqdatCore.Model.Helper, as: ModelHelper
  import Ecto.Query

  def create(params) do
    changeset = Sensor.changeset(%Sensor{}, params)
    Repo.insert(changeset)
  end

  def update(sensor, params) do
    changeset = Sensor.update_changeset(sensor, params)
    Repo.update(changeset)
  end

  def get(id) when is_integer(id) do
    case Repo.get(Sensor, id) do
      nil ->
        {:error, "not found"}

      sensor ->
        {:ok, sensor}
    end
  end

  def get(query) when is_map(query) do
    case Repo.get_by(Sensor, query) do
      nil ->
        {:error, "not found"}

      sensor ->
        {:ok, sensor}
    end
  end

  def get_all_by_parent_project(project_id) do
    Sensor
    |> where([sensor], sensor.project_id == ^project_id)
    |> where([sensor], sensor.parent_type == "Project")
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

  def get_all_by_assets(%{
        page_size: page_size,
        page_number: page_number,
        project_id: project_id,
        org_id: org_id
      }) do
    Sensor
    |> where([sensor], sensor.project_id == ^project_id)
    |> where([sensor], sensor.org_id == ^org_id)
    |> order_by(:id)
    |> Repo.paginate(page: page_number, page_size: page_size)
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

  def child_sensors_query(root) when is_list(root) == false do
    from(sensor in Sensor,
      where: sensor.parent_id == ^root.id and sensor.parent_type == "Asset"
    )
  end

  def child_sensors_query(asset_ids) when is_list(asset_ids) do
    from(sensor in Sensor,
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

  def delete(id) do
    sensor = Sensor |> Repo.get(id)

    case sensor.has_timesrs_data do
      false ->
        Repo.delete(sensor)

      true ->
        {:error,
         "Sensor #{sensor.name} contains time-series data. Please delete sensors data before deleting sensor."}
    end
  end

  def delete_all(parent_asset_ids) do
    query =
      from(sensor in Sensor,
        where:
          sensor.parent_id in ^parent_asset_ids and sensor.parent_type == "Asset" and
            sensor.has_timesrs_data == true
      )

    case Repo.all(query) do
      [] ->
        child_sensors_query(parent_asset_ids)
        |> Repo.delete_all()

      _ ->
        {:error, "This hirerachy contains sensors data. Please delete all sensors data first."}
    end
  end

  def insert_data(sensor, sensor_data) do
    params = %{
      sensor_id: sensor.id,
      datapoint: sensor_data,
      inserted_timestamp: DateTime.utc_now()
    }

    changeset = SensorData.changeset(%SensorData{}, params)

    Repo.insert(changeset)
  end

  def sensor_data(sensor_id, identifier) do
    query =
      from(
        data in SensorData,
        where: data.sensor_id == ^sensor_id,
        order_by: data.inserted_timestamp,
        select: [data.inserted_timestamp, fragment("? ->> ?", data.datapoint, ^identifier)]
      )

    stream = Repo.stream(query)

    {:ok, result} =
      Repo.transaction(fn ->
        Enum.map(stream, fn [date, value] ->
          {value, _} = Float.parse(value)
          [DateTime.to_unix(date, :millisecond), value]
        end)
      end)

    result
  end
end
