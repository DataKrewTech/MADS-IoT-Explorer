defmodule AcqdatCore.Model.EntityManagement.AssetType do
  alias AcqdatCore.Repo
  # , Asset}
  alias AcqdatCore.Schema.EntityManagement.{Asset, AssetType}
  alias AcqdatCore.Model.EntityManagement.SensorType, as: STModel
  alias AcqdatCore.Model.Helper, as: ModelHelper
  import Ecto.Query

  def create(params) do
    changeset = AssetType.changeset(%AssetType{}, params)
    Repo.insert(changeset)
  end

  def get(id) when is_integer(id) do
    case Repo.get(AssetType, id) do
      nil ->
        {:error, "not found"}

      asset_type ->
        {:ok, asset_type}
    end
  end

  def get_all(%{
        page_size: page_size,
        page_number: page_number,
        org_id: org_id,
        project_id: project_id
      }) do
    query =
      from(asset_type in AssetType,
        where: asset_type.org_id == ^org_id and asset_type.project_id == ^project_id,
        order_by: asset_type.id
      )

    query |> Repo.paginate(page: page_number, page_size: page_size)
  end

  def get_all(
        %{page_size: page_size, page_number: page_number, org_id: org_id, project_id: project_id},
        preloads
      ) do
    query =
      from(asset_type in AssetType,
        where: asset_type.org_id == ^org_id and asset_type.project_id == ^project_id,
        order_by: asset_type.id
      )

    paginated_asset_data = query |> Repo.paginate(page: page_number, page_size: page_size)

    asset_data_with_preloads = paginated_asset_data.entries |> Repo.preload(preloads)

    ModelHelper.paginated_response(asset_data_with_preloads, paginated_asset_data)
  end

  def update(asset_type, params) do
    case is_nil(asset_present?(asset_type)) do
      true ->
        changeset = AssetType.update_changeset(asset_type, params)

        case Repo.update(changeset) do
          {:ok, asset_type} -> {:ok, asset_type |> Repo.preload(:org)}
          {:error, error} -> {:error, error}
        end

      false ->
        {:error, "There are assets associated with this Asset Type"}
    end
  end

  def delete(asset_type) do
    case is_nil(asset_present?(asset_type)) do
      true ->
        case Repo.delete(asset_type) do
          {:ok, asset_type} -> {:ok, asset_type |> Repo.preload(:org)}
          {:error, error} -> {:error, error}
        end

      false ->
        {:error, "There are assets associated with this Asset Type. Please delete Asset first."}
    end
  end

  defp asset_present?(asset_type) do
    query =
      from(asset in Asset,
        where: asset.asset_type_id == ^asset_type.id
      )

    List.first(Repo.all(query))
  end

  def add_sensor_type(params) do
    %{
      name: name,
      description: description,
      metadata: metadata,
      parameters: parameters,
      org_id: org_id,
      project_id: project_id
    } = params

    params = %{
      name: name <> "-sensor-type",
      description: description,
      metadata: metadata,
      parameters: parameters,
      org_id: org_id,
      generated_by: "asset",
      project_id: project_id
    }

    case STModel.create(params) do
      {:ok, sensor_type} -> {:ok, sensor_type}
      {:error, message} -> {:error, message}
    end
  end
end
