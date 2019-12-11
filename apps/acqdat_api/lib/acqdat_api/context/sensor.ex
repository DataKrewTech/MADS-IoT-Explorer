defmodule AcqdatApi.Context.Sensor do
  alias AcqdatCore.Model.Sensor, as: SensorModel

  def sensor_by_criteria(%{"device_id" => device_id} = criteria) do
    {device_id, _} = Integer.parse(device_id)
    {:list, SensorModel.get_all_by_device(device_id, [:sensor_type])}
  end
end
