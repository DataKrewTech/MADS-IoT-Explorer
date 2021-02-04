defmodule AcqdatApi.EntityManagement.Asset do
  alias AcqdatCore.Model.EntityManagement.Asset, as: AssetModel
  alias AcqdatCore.Model.EntityManagement.Organisation, as: OrgModel
  import AcqdatApiWeb.Helpers
  alias AcqdatCore.Repo
  alias AcqdatApiWeb.EntityManagement.AssetErrorHelper
  alias AcqdatCore.Schema.EntityManagement.{Asset}

  defdelegate asset_descendants(id), to: AssetModel
  defdelegate get(id), to: AssetModel

  defdelegate update_asset(asset, data), to: AssetModel
  defdelegate get_all(data, preloads), to: AssetModel
  defdelegate delete(asset), to: AssetModel
  defdelegate get(org_id, project_id), to: OrgModel

  def create(params) do
    params = params_extraction(params)

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
    AssetModel.add_as_child(root, child, :child)
  end

  defp verify_asset({:ok, asset}) do
    {:ok, asset |> Repo.preload([:asset_type])}
  end

  defp verify_asset({:error, %Ecto.ConstraintError{constraint: constraint}}) do
    {:error, %{error: AssetErrorHelper.error_message(String.to_atom(constraint))}}
  end

  defp verify_asset({:error, asset}) do
    {:error, %{error: extract_changeset_error(asset)}}
  end

  defp prepare_asset(params) do
    metadata =
      Enum.reduce(params.metadata, [], fn x, acc ->
        x = x |> Map.new(fn {k, v} -> {String.to_atom(k), v} end)
        [x | acc]
      end)

    Repo.preload(
      %Asset{
        creator_id: params.creator_id,
        description: params.description,
        image_url: params.image_url,
        mapped_parameters: params.mapped_parameters,
        metadata: metadata,
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

  defp params_extraction(params) do
    Map.from_struct(params)
    |> Map.drop([:_id, :__meta__])
  end
end
