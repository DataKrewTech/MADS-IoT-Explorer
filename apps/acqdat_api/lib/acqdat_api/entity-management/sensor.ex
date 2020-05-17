defmodule AcqdatApi.EntityManagement.Sensor do
  alias AcqdatCore.Model.EntityManagement.Sensor, as: SensorModel
  import AcqdatApiWeb.Helpers

  def create(attrs) do
    # sensor_details = sensor_create_attrs(params)

    verify_sensor(SensorModel.create(sensor_create_attrs(attrs)))
  end

  defp sensor_create_attrs(%{
         sensor_type_id: sensor_type_id,
         description: description,
         metadata: metadata,
         name: name,
         org_id: org_id,
         parent_id: parent_id,
         parent_type: parent_type,
         project_id: project_id
       }) do
    %{
      sensor_type_id: sensor_type_id,
      description: description,
      metadata: metadata,
      name: name,
      org_id: org_id,
      parent_id: parent_id,
      parent_type: parent_type,
      project_id: project_id
    }
  end

  defp verify_sensor({:ok, sensor}) do
    {:ok,
     %{
       id: sensor.id,
       name: sensor.name,
       uuid: sensor.uuid
     }}
  end

  defp verify_sensor({:error, sensor}) do
    {:error, %{error: extract_changeset_error(sensor)}}
  end
end
