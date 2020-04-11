defmodule AcqdatApi.Sensor do
  alias AcqdatCore.Model.Sensor, as: SensorModel
  import AcqdatApiWeb.Helpers

  def create(params) do
    %{
      name: name
    } = params

    verify_sensor(
      SensorModel.create(%{
        name: name
      })
    )
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
