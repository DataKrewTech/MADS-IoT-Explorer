defmodule AcqdatCore.Model.EntityManagement.AssetType do
  alias AcqdatCore.Repo
  # , Asset}
  alias AcqdatCore.Schema.EntityManagement.{AssetType}
  alias AcqdatCore.Model.EntityManagement.SensorType, as: STModel
  alias AcqdatCore.Model.Helper, as: ModelHelper
  import Ecto.Query

  @spec create(%{optional(:__struct__) => none, optional(atom | binary) => any}) :: any
  def create(params) do
    changeset = AssetType.changeset(%AssetType{}, params)
    Repo.insert(changeset)
  end

  @spec get(integer) :: {:error, <<_::72>>} | {:ok, any}
  def get(id) when is_integer(id) do
    case Repo.get(AssetType, id) do
      nil ->
        {:error, "not found"}

      asset_type ->
        {:ok, asset_type}
    end
  end

  @spec get_all(%{page_number: any, page_size: any}) :: Scrivener.Page.t()
  def get_all(%{page_size: page_size, page_number: page_number}) do
    AssetType |> order_by(:id) |> Repo.paginate(page: page_number, page_size: page_size)
  end

  @spec get_all(%{page_number: any, page_size: any}, atom | [any]) :: %{
          entries: any,
          page_number: any,
          page_size: any,
          total_entries: any,
          total_pages: any
        }
  def get_all(%{page_size: page_size, page_number: page_number}, preloads) do
    paginated_asset_data =
      AssetType |> order_by(:id) |> Repo.paginate(page: page_number, page_size: page_size)

    asset_data_with_preloads = paginated_asset_data.entries |> Repo.preload(preloads)

    ModelHelper.paginated_response(asset_data_with_preloads, paginated_asset_data)
  end

  # @spec update(
  #         AcqdatCore.Schema.AssetType.t(),
  #         :invalid | %{optional(:__struct__) => none, optional(atom | binary) => any}
  #       ) :: any
  # def update(asset_type, params) do
  #   case is_nil(check_sensor_relation(asset_type)) do
  #     true ->
  #       changeset = AssetType.update_changeset(asset_type, params)

  #       case Repo.update(changeset) do
  #         {:ok, asset_type} -> {:ok, asset_type |> Repo.preload(:org)}
  #         {:error, error} -> {:error, error}
  #       end

  #     false ->
  #       {:error, "Sensor is Associated to this Sensor Type"}
  #   end
  # end

  # @spec delete(%{__struct__: atom | %{__changeset__: any}}) :: any
  # def delete(asset_type) do
  #   case is_nil(check_sensor_relation(asset_type)) do
  #     true ->
  #       case Repo.delete(asset_type) do
  #         {:ok, asset_type} -> {:ok, asset_type |> Repo.preload(:org)}
  #         {:error, error} -> {:error, error}
  #       end

  #     false ->
  #       {:error, "Sensor is Associated to this Sensor Type"}
  #   end
  # end

  def add_sensor_type(params) do
    %{
      name: name,
      description: description,
      metadata: metadata,
      parameters: parameters,
      org_id: org_id
    } = params

    params = %{
      name: name <> "-sensor-type",
      description: description,
      metadata: metadata,
      parameters: parameters,
      org_id: org_id,
      generated_by: "asset"
    }

    case STModel.create(params) do
      {:ok, sensor_type} -> {:ok, sensor_type}
      {:error, message} -> {:error, message}
    end
  end
end
