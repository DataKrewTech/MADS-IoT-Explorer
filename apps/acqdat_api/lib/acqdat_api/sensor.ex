defmodule AcqdatApi.Sensor do
  alias AcqdatCore.Schema.Sensor
  alias AcqdatCore.Model.Sensor, as: SensorModel
  import AcqdatApiWeb.Helpers

  def create(params) do
    %{
      name: name,
      device_id: device_id,
      sensor_type_id: sensor_type_id
    } = params

    verify_sensor(
      SensorModel.create(%{
        name: name,
        device_id: device_id,
        sensor_type_id: sensor_type_id
      })
    )
  end

  defp verify_sensor({:ok, sensor}) do
    {:ok,
     %{
       id: sensor.id,
       name: sensor.name,
       device_id: sensor.device_id,
       sensor_type_id: sensor.sensor_type_id,
       uuid: sensor.uuid
     }}
  end

  defp verify_sensor({:error, sensor}) do
    {:error, %{error: extract_changeset_error(sensor)}}
  end
end
