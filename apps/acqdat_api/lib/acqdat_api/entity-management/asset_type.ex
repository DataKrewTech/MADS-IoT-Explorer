defmodule AcqdatApi.EntityManagement.AssetType do
  alias AcqdatCore.Model.EntityManagement.AssetType, as: AssetTypeModel
  import AcqdatApiWeb.Helpers
  alias AcqdatCore.Repo

  defdelegate get(id), to: AssetTypeModel
  defdelegate update(asset_type, data), to: AssetTypeModel
  defdelegate delete(asset_type), to: AssetTypeModel
  defdelegate get_all(data, preloads), to: AssetTypeModel
  defdelegate get_all(data), to: AssetTypeModel

  def create(params) do
    %{
      sensor_type_present: sensor_type_present
    } = params

    case sensor_type_present do
      true -> verify_sensor_type_creation(AssetTypeModel.add_sensor_type(params), params)
      false -> create_asset(params)
    end
  end

  defp verify_sensor_type_creation({:ok, sensor_type}, params) do
    %{
      name: name,
      description: description,
      metadata: metadata,
      parameters: parameters,
      org_id: org_id,
      project_id: project_id
    } = params

    create_asset(%{
      name: name,
      description: description,
      metadata: metadata,
      parameters: parameters,
      sensor_type_present: true,
      sensor_type_uuid: sensor_type.uuid,
      org_id: org_id,
      project_id: project_id
    })
  end

  defp verify_sensor_type_creation({:error, sensor_type}, _params) do
    {:error, %{error: extract_changeset_error(sensor_type)}}
  end

  def create_asset(params) do
    %{
      name: name,
      description: description,
      metadata: metadata,
      parameters: parameters,
      sensor_type_present: sensor_type_present,
      sensor_type_uuid: sensor_type_uuid,
      org_id: org_id,
      project_id: project_id
    } = params

    verify_asset_type(
      AssetTypeModel.create(%{
        name: name,
        description: description,
        metadata: metadata,
        parameters: parameters,
        sensor_type_present: sensor_type_present,
        sensor_type_uuid: sensor_type_uuid,
        org_id: org_id,
        project_id: project_id
      })
    )
  end

  defp verify_asset_type({:ok, asset_type}) do
    asset_type = Repo.preload(asset_type, [:org, :project])

    {:ok,
     %{
       id: asset_type.id,
       name: asset_type.name,
       description: asset_type.description,
       metadata: asset_type.metadata,
       parameters: asset_type.parameters,
       org_id: asset_type.org_id,
       slug: asset_type.slug,
       uuid: asset_type.uuid,
       sensor_type_present: asset_type.sensor_type_present,
       sensor_type_uuid: asset_type.sensor_type_uuid,
       org: asset_type.org,
       project_id: asset_type.project_id,
       project: asset_type.project
     }}
  end

  defp verify_asset_type({:error, asset_type}) do
    {:error, %{error: extract_changeset_error(asset_type)}}
  end
end
