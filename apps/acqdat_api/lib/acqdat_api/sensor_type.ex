defmodule AcqdatApi.SensorType do
  alias AcqdatCore.Model.SensorType, as: SensorTypeModel
  import AcqdatApiWeb.Helpers

  def create(params) do
    %{
      name: name,
      make: make,
      value_keys: value_keys,
      visualizer: visualizer,
      identifier: identifier
    } = params

    verify_sensor_type(
      SensorTypeModel.create(%{
        name: name,
        make: make,
        value_keys: value_keys,
        visualizer: visualizer,
        identifier: identifier
      })
    )
  end

  defp verify_sensor_type({:ok, sensor_type}) do
    {:ok,
     %{
       id: sensor_type.id,
       name: sensor_type.name,
       make: sensor_type.make,
       identifier: sensor_type.identifier
     }}
  end

  defp verify_sensor_type({:error, sensor_type}) do
    {:error, %{error: extract_changeset_error(sensor_type)}}
  end
end
