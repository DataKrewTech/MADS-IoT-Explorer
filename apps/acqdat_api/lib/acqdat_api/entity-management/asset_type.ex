defmodule AcqdatApi.EntityManagement.AssetType do
  import AcqdatApiWeb.Helpers
  alias AcqdatCore.Model.EntityManagement.AssetType, as: AssetTypeModel

  defdelegate get(id), to: AssetTypeModel
  defdelegate update(asset_type, data), to: AssetTypeModel
  defdelegate delete(asset_type), to: AssetTypeModel
  defdelegate get_all(data, preloads), to: AssetTypeModel

  def create(params) do
    %{
      name: name,
      description: description,
      metadata: metadata,
      parameters: parameters,
      org_id: org_id,
      project_id: project_id
    } = params

    verify_asset_type(
      AssetTypeModel.create(%{
        name: name,
        description: description,
        metadata: metadata,
        parameters: parameters,
        org_id: org_id,
        project_id: project_id
      })
    )
  end

  defp verify_asset_type({:ok, asset_type}) do
    {:ok, asset_type}
  end

  defp verify_asset_type({:error, asset_type}) do
    {:error, %{error: extract_changeset_error(asset_type)}}
  end
end
