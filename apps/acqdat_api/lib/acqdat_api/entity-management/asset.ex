defmodule AcqdatApi.EntityManagement.Asset do
  alias AcqdatCore.Model.EntityManagement.Asset, as: AssetModel
  alias AcqdatCore.Model.EntityManagement.Organisation, as: OrgModel
  import AcqdatApiWeb.Helpers
  alias AcqdatCore.Repo
  alias AcqdatCore.Schema.EntityManagement.{Organisation, Asset}

  defdelegate asset_descendants(id), to: AssetModel
  defdelegate get(id), to: AssetModel

  @spec update_asset(AcqdatCore.Schema.EntityManagement.Asset.t(), map) ::
          {:error, Ecto.Changeset.t()} | {:ok, AcqdatCore.Schema.EntityManagement.Asset.t()}
  defdelegate update_asset(asset, data), to: AssetModel
  defdelegate get_all(data, preloads), to: AssetModel
  defdelegate delete(asset), to: AssetModel
  defdelegate get(org_id, project_id), to: OrgModel

  def create(params, asset_type) do
    params = params_extraction(params, asset_type)

    case is_nil(params.parent_id) do
      true ->
        verify_asset(add_asset_as_root(params))

      false ->
        root = AssetModel.fetch_root(params.org_id, params.parent_id)
        verify_asset(add_asset_as_child(root, params))
    end
  end

  defp add_asset_as_root(params) do
    asset = prepare_asset(params)
    asset = Map.put(asset, :org_name, asset.org.name)
    AssetModel.add_as_root(asset)
  end

  defp add_asset_as_child(root, params) do
    child = prepare_asset(params)
    AssetModel.add_as_child(root, child.name, params.org_id, :child)
  end

  defp verify_asset({:ok, asset}) do
    {:ok,
     %{
       id: asset.id,
       creator_id: asset.creator_id,
       description: asset.description,
       image_url: asset.image_url,
       mapped_parameters: asset.mapped_parameters,
       uuid: asset.uuid,
       slug: asset.slug,
       metadata: asset.metadata,
       name: asset.name,
       project_id: asset.project_id,
       org_id: asset.org_id,
       owner_id: asset.owner_id,
       parent_id: asset.parent_id,
       asset_type_id: asset.asset_type_id,
       properties: asset.properties,
       org: asset.org
     }}
  end

  defp verify_asset({:error, asset}) do
    {:error, %{error: extract_changeset_error(asset)}}
  end

  defp prepare_asset(params) do
    org = Repo.get!(Organisation, params.org_id)
    %Ecto.Changeset{changes: changes} = Asset.changeset(%Asset{}, params)

    mapped_parameters =
      case Map.has_key?(changes, :mapped_parameters) do
        true ->
          %{mapped_parameters: mapped_parameters} = changes

          Enum.reduce(mapped_parameters, [], fn x, acc ->
            %Ecto.Changeset{changes: changes} = x
            [changes | acc]
          end)

        false ->
          nil
      end

    Repo.preload(
      %Asset{
        creator_id: params.creator_id,
        description: params.description,
        image_url: params.image_url,
        mapped_parameters: mapped_parameters,
        uuid: UUID.uuid1(:hex),
        slug: Slugger.slugify(org.name <> params.name),
        metadata: params.metadata,
        name: params.name,
        org_id: params.org_id,
        owner_id: params.owner_id,
        parent_id: params.parent_id,
        project_id: params.project_id,
        asset_type_id: params.asset_type_id,
        properties: params.properties
      },
      :org
    )
  end

  defp params_extraction(params, asset_type) do
    %{
      creator_id: creator_id,
      description: description,
      image_url: image_url,
      mapped_parameters: mapped_parameters,
      name: name,
      org_id: org_id,
      owner_id: owner_id,
      parent_id: parent_id,
      project_id: project_id,
      properties: properties,
      asset_type_id: asset_type_id
    } = params

    metadata =
      Enum.reduce(asset_type.metadata, [], fn x, acc ->
        {_, x} = Map.from_struct(x) |> Map.pop(:id)
        acc ++ [x]
      end)

    %{
      creator_id: creator_id,
      description: description,
      image_url: image_url,
      mapped_parameters: mapped_parameters,
      metadata: metadata,
      name: name,
      org_id: org_id,
      owner_id: owner_id,
      parent_id: parent_id,
      project_id: project_id,
      properties: properties,
      asset_type_id: asset_type_id
    }
  end
end
