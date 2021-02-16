defmodule AcqdatCore.Model.EntityManagement.SensorType do
  alias AcqdatCore.Repo
  alias AcqdatCore.Schema.EntityManagement.{SensorType, Sensor}
  alias AcqdatCore.Model.Helper, as: ModelHelper
  import Ecto.Query

  @spec create(%{optional(:__struct__) => none, optional(atom | binary) => any}) :: any
  def create(params) do
    changeset = SensorType.changeset(%SensorType{}, params)
    Repo.insert(changeset)
  end

  @spec get(integer) :: {:error, <<_::72>>} | {:ok, any}
  def get(id) when is_integer(id) do
    case Repo.get(SensorType, id) do
      nil ->
        {:error, "not found"}

      sensor_type ->
        {:ok, sensor_type}
    end
  end

  def get(params) when is_map(params) do
    case Repo.get_by(SensorType, params) do
      nil ->
        {:error, "SensorType not found"}

      sensor_type ->
        {:ok, sensor_type}
    end
  end

  def get_all(%{org_id: org_id, project_id: project_id}) do
    SensorType
    |> where([sensor_type], sensor_type.project_id == ^project_id)
    |> where([sensor_type], sensor_type.org_id == ^org_id)
    |> order_by(:id)
    |> Repo.all()
  end

  def get_all(%{
        page_size: page_size,
        page_number: page_number,
        project_id: project_id,
        org_id: org_id
      }) do
    SensorType
    |> where([sensor_type], sensor_type.project_id == ^project_id)
    |> where([sensor_type], sensor_type.org_id == ^org_id)
    |> order_by(:id)
    |> Repo.paginate(page: page_number, page_size: page_size)
  end

  def get_all(
        %{page_size: page_size, page_number: page_number, project_id: project_id, org_id: org_id},
        preloads
      ) do
    paginated_sensor_data =
      SensorType
      |> where([sensor_type], sensor_type.project_id == ^project_id)
      |> where([sensor_type], sensor_type.org_id == ^org_id)
      |> order_by(:id)
      |> Repo.paginate(page: page_number, page_size: page_size)

    sensor_data_with_preloads = paginated_sensor_data.entries |> Repo.preload(preloads)

    ModelHelper.paginated_response(sensor_data_with_preloads, paginated_sensor_data)
  end

  def update(sensor_type, params) do
    case check_for_parameters_and_metadata(params) do
      true ->
        case is_nil(check_sensor_relation(sensor_type)) do
          true ->
            changeset = SensorType.update_changeset(sensor_type, params)

            case Repo.update(changeset) do
              {:ok, sensor_type} -> {:ok, sensor_type |> Repo.preload(:org)}
              {:error, error} -> {:error, error}
            end

          false ->
            {:error, "Sensor is Associated to this Sensor Type"}
        end

      false ->
        changeset = SensorType.update_changeset(sensor_type, params)

        case Repo.update(changeset) do
          {:ok, sensor_type} -> {:ok, sensor_type |> Repo.preload(:org)}
          {:error, error} -> {:error, error}
        end
    end
  end

  def fetch_uniq_param_name_by_param_uuid(sensor_type_id, parameter_uuids) do
    query =
      from(sensor_type in SensorType,
        cross_join: c in fragment("unnest(?)", sensor_type.parameters),
        where:
          fragment("?->>'uuid'", c) in ^parameter_uuids and sensor_type.id == ^sensor_type_id,
        group_by: fragment("?->>'uuid'", c),
        select: %{
          name: fragment("ARRAY_AGG(DISTINCT ?->>'name')", c),
          uuid: fragment("?->>'uuid'", c)
        }
      )

    Repo.all(query)
  end

  defp check_for_parameters_and_metadata(params) do
    Map.has_key?(params, "parameters") or Map.has_key?(params, "metadata")
  end

  def check_sensor_relation(sensor_type) do
    query =
      from(sensor in Sensor,
        where: sensor.sensor_type_id == ^sensor_type.id
      )

    List.first(Repo.all(query))
  end

  def delete(sensor_type) do
    case is_nil(check_sensor_relation(sensor_type)) do
      true ->
        case Repo.delete(sensor_type) do
          {:ok, sensor_type} -> {:ok, sensor_type |> Repo.preload(:org)}
          {:error, error} -> {:error, error}
        end

      false ->
        {:error, "Sensor is Associated to this Sensor Type"}
    end
  end
end
