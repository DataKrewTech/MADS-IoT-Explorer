defmodule AcqdatApiWeb.EntityManagement.SensorView do
  use AcqdatApiWeb, :view
  alias AcqdatApiWeb.EntityManagement.{SensorView, SensorTypeView}

  def render("sensor.json", %{sensor: sensor}) do
    %{
      id: sensor.id,
      name: sensor.name,
      uuid: sensor.uuid,
      parent_id: sensor.parent_id,
      parent_type: sensor.parent_type,
      metadata: render_many(sensor.metadata, SensorView, "metadata.json")
    }
  end

  def render("sensor_tree.json", %{sensor: sensor}) do
    %{
      type: "Sensor",
      id: sensor.id,
      parent_id: sensor.parent_id,
      parent_type: sensor.parent_type,
      sensor_type_id: sensor.sensor_type_id,
      name: sensor.name,
      sensor_type: render_one(sensor.sensor_type, SensorTypeView, "sensor_type.json"),
      entities: render_many(sensor.parameters, SensorView, "data_tree.json"),
      metadata: render_many(sensor.metadata, SensorView, "metadata.json")
    }
  end

  def render("metadata.json", %{sensor: metadata}) do
    %{
      id: metadata.id,
      name: metadata.name,
      data_type: metadata.data_type,
      unit: metadata.unit,
      uuid: metadata.uuid
    }
  end

  def render("sensor_with_preloads.json", %{sensor: sensor}) do
    %{
      id: sensor.id,
      name: sensor.name,
      uuid: sensor.uuid,
      parent_id: sensor.parent_id,
      parent_type: sensor.parent_type,
      metadata: render_many(sensor.metadata, SensorView, "metadata.json")
    }
  end

  def render("sensors_details.json", %{sensor: sensor}) do
    %{
      id: sensor.id,
      name: sensor.name,
      uuid: sensor.uuid
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

  def render("sensors_by_criteria_with_preloads.json", %{sensors_by_criteria: sensors_by_criteria}) do
    %{
      sensors: render_many(sensors_by_criteria, SensorView, "sensors_details.json")
    }
  end

  def render("metadata.json", %{sensor: metadata}) do
    %{
      id: metadata.id,
      name: metadata.name,
      data_type: metadata.data_type,
      unit: metadata.unit,
      uuid: metadata.uuid,
      value: metadata.value
    }
  end
end
