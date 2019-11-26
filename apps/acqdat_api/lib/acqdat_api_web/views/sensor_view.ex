defmodule AcqdatApiWeb.SensorView do
  use AcqdatApiWeb, :view
  alias AcqdatApiWeb.SensorView
  alias AcqdatApiWeb.DeviceView
  alias AcqdatApiWeb.SensorTypeView

  def render("sensor.json", %{sensor: sensor}) do
    %{
      id: sensor.id,
      name: sensor.name,
      uuid: sensor.uuid,
      device_id: sensor.device_id,
      sensor_type_id: sensor.sensor_type_id
    }
  end

  def render("sensor_with_preloads.json", %{sensor: sensor}) do
    %{
      id: sensor.id,
      name: sensor.name,
      uuid: sensor.uuid,
      device_id: sensor.device_id,
      sensor_type_id: sensor.sensor_type_id,
      device: render_one(sensor.device, DeviceView, "device.json"),
      sensor_type: render_one(sensor.sensor_type, SensorTypeView, "sensor_type.json")
    }
  end

  def render("device_sensor_with_preloads.json", %{sensor: sensor}) do
    %{
      id: sensor.id,
      name: sensor.name,
      uuid: sensor.uuid,
      device_id: sensor.device_id,
      sensor_type_id: sensor.sensor_type_id,
      sensor_type: render_one(sensor.sensor_type, SensorTypeView, "sensor_type.json")
    }
  end

  def render("index.json", sensor) do
    %{
      sensors: render_many(sensor.entries, SensorView, "sensor_with_preloads.json"),
      page_number: sensor.page_number,
      page_size: sensor.page_size,
      total_entries: sensor.total_entries,
      total_pages: sensor.total_pages
    }
  end

  def render("device_sensor_with_preloads.json", %{device_sensors: device_sensors}) do
    %{
      sensors: render_many(device_sensors, SensorView, "device_sensor_with_preloads.json"),
    }
  end
end
