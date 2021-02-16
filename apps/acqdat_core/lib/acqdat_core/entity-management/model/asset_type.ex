defmodule AcqdatCore.Model.EntityManagement.AssetType do
  alias AcqdatCore.Repo
  alias AcqdatCore.Schema.EntityManagement.{Asset, AssetType}
  alias AcqdatCore.Model.Helper, as: ModelHelper
  import Ecto.Query

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

  def get(params) when is_map(params) do
    case Repo.get_by(AssetType, params) do
      nil ->
        {:error, "AssetType not found"}

      asset_type ->
        {:ok, asset_type}
    end
  end

  def get_all(%{org_id: org_id, project_id: project_id}) do
    query =
      from(asset_type in AssetType,
        where: asset_type.org_id == ^org_id and asset_type.project_id == ^project_id,
        order_by: asset_type.id
      )

    query |> Repo.all()
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

  @spec update(AssetType.t(), map) ::
          {:ok, AssetType.t()}
          | {:error, Ecto.Changeset.t()}
          | {:error, String.t()}
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

  def fetch_uniq_metadata_name_by_metadata_uuid(asset_type_id, metadata_uuids) do
    query =
      from(asset in AssetType,
        cross_join: c in fragment("unnest(?)", asset.metadata),
        where: fragment("?->>'uuid'", c) in ^metadata_uuids and asset.id == ^asset_type_id,
        group_by: fragment("?->>'uuid'", c),
        select: %{
          name: fragment("ARRAY_AGG(DISTINCT ?->>'name')", c),
          uuid: fragment("?->>'uuid'", c)
        }
      )

    Repo.all(query)
  end

  defp asset_present?(asset_type) do
    query =
      from(asset in Asset,
        where: asset.asset_type_id == ^asset_type.id
      )

    List.first(Repo.all(query))
  end
end
