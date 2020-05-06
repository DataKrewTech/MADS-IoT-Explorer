defmodule AcqdatCore.Model.SensorType do
  alias AcqdatCore.Repo
  alias AcqdatCore.Schema.SensorType
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

  @spec get_all(%{page_number: any, page_size: any}) :: Scrivener.Page.t()
  def get_all(%{page_size: page_size, page_number: page_number}) do
    SensorType |> order_by(:id) |> Repo.paginate(page: page_number, page_size: page_size)
  end

  @spec get_all(%{page_number: any, page_size: any}, atom | [any]) :: %{
          entries: any,
          page_number: any,
          page_size: any,
          total_entries: any,
          total_pages: any
        }
  def get_all(%{page_size: page_size, page_number: page_number}, preloads) do
    paginated_sensor_data =
      SensorType |> order_by(:id) |> Repo.paginate(page: page_number, page_size: page_size)

    sensor_data_with_preloads = paginated_sensor_data.entries |> Repo.preload(preloads)

    ModelHelper.paginated_response(sensor_data_with_preloads, paginated_sensor_data)
  end

  @spec update(
          AcqdatCore.Schema.SensorType.t(),
          :invalid | %{optional(:__struct__) => none, optional(atom | binary) => any}
        ) :: any
  def update(sensor_type, params) do
    changeset = SensorType.update_changeset(sensor_type, params)
    Repo.update(changeset)
  end

  @spec delete(%{__struct__: atom | %{__changeset__: any}}) :: any
  def delete(sensor_type) do
    Repo.delete!(sensor_type)
  end
end
