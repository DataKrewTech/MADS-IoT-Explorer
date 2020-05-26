defmodule AcqdatApi.EntityManagement.SensorType do
  alias AcqdatCore.Model.EntityManagement.SensorType, as: SensorTypeModel
  import AcqdatApiWeb.Helpers
  alias AcqdatCore.Repo

  defdelegate update(sensor_type, data), to: SensorTypeModel
  defdelegate get_all(data, preloads), to: SensorTypeModel
  defdelegate delete(sensor_type), to: SensorTypeModel
  # defdelegate get(org_id, project_id), to: OrgModel

  def create(params) do
    %{
      name: name,
      description: description,
      metadata: metadata,
      parameters: parameters,
      org_id: org_id,
      project_id: project_id
    } = params

    verify_sensor_type(
      SensorTypeModel.create(%{
        name: name,
        description: description,
        metadata: metadata,
        parameters: parameters,
        org_id: org_id,
        project_id: project_id
      })
    )
  end

  defp verify_sensor_type({:ok, sensor_type}) do
    sensor_type = Repo.preload(sensor_type, :org)

    {:ok,
     %{
       id: sensor_type.id,
       name: sensor_type.name,
       description: sensor_type.description,
       metadata: sensor_type.metadata,
       parameters: sensor_type.parameters,
       org_id: sensor_type.org_id,
       slug: sensor_type.slug,
       project_id: sensor_type.project_id,
       uuid: sensor_type.uuid,
       org: sensor_type.org
     }}
  end

  defp verify_sensor_type({:error, sensor_type}) do
    {:error, %{error: extract_changeset_error(sensor_type)}}
  end
end
