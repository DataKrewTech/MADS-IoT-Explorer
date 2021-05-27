defmodule AcqdatCore.Model.EntityManagement.AssetType do
  alias AcqdatCore.Repo
  alias AcqdatCore.Schema.EntityManagement.{Asset, AssetType}
  alias AcqdatCore.Model.Helper, as: ModelHelper
  import Ecto.Query

  def create(params) do
    changeset = AssetType.changeset(%AssetType{}, params)
    Repo.insert(changeset)
  end

  def return_count(%{"type" => "AssetType", "project_id" => project_id}) do
    query =
      from(p in AssetType,
        where: p.project_id == ^project_id,
        select: count(p.id)
      )

    Repo.one(query)
  end

  def return_count(%{"type" => "AssetType"}) do
    query =
      from(p in AssetType,
        select: count(p.id)
      )

    Repo.one(query)
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
        update_asset_type(asset_type, params)

      false ->
        validate_n_append_metadata(asset_type, params)
    end
  end

  def validate_n_append_metadata(asset_type, %{"metadata" => metadata} = params) do
    new_metadata_params =
      Enum.filter(metadata, fn param -> param["id"] == nil && param["uuid"] == nil end)

    if length(new_metadata_params) > 0 do
      metadata =
        Enum.map(asset_type.metadata, fn metadata -> Map.from_struct(metadata) end) ++
          new_metadata_params

      params = %{params | "metadata" => metadata}

      update_asset_type(asset_type, params)
    else
      {:error, "There are assets associated with this Asset Type"}
    end
  end

  def validate_n_append_metadata(asset_type, params) do
    update_asset_type(asset_type, params)
  end

  defp update_asset_type(asset_type, params) do
    changeset = AssetType.update_changeset(asset_type, params)

    case Repo.update(changeset) do
      {:ok, asset_type} -> {:ok, asset_type |> Repo.preload(:org)}
      {:error, error} -> {:error, error}
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
