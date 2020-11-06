defmodule AcqdatApiWeb.EntityManagement.SensorView do
  use AcqdatApiWeb, :view
  alias AcqdatApiWeb.EntityManagement.{SensorView, SensorTypeView}
  alias AcqdatApiWeb.IotManager.GatewayView

  def render("sensor.json", %{sensor: sensor}) do
    %{
      id: sensor.id,
      name: sensor.name,
      uuid: sensor.uuid,
      parent_id: sensor.parent_id,
      parent_type: sensor.parent_type,
      sensor_type_id: sensor.sensor_type_id,
      description: sensor.description,
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
      entities: render_many(sensor.sensor_type.parameters, SensorView, "sensor_parameters.json"),
      sensor_type: render_one(sensor.sensor_type, SensorTypeView, "sensor_type.json"),
      metadata: render_many(sensor.metadata, SensorView, "metadata.json"),
      gateway: render_one(sensor.gateway, GatewayView, "gist.json")
    }
  end

  def render("sensor_parameters.json", %{sensor: parameter}) do
    %{
      id: parameter.id,
      name: parameter.name,
      data_type: parameter.data_type,
      unit: parameter.unit,
      uuid: parameter.uuid,
      type: "SensorParameter"
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

  def render("sensor_with_preloads.json", %{sensor: sensor}) do
    %{
      id: sensor.id,
      name: sensor.name,
      uuid: sensor.uuid,
      description: sensor.description,
      parent_id: sensor.parent_id,
      parent_type: sensor.parent_type,
      sensor_type: render_one(sensor.sensor_type, SensorTypeView, "sensor_type.json"),
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

  def render("hits.json", %{hits: hits}) do
    %{
      sensors: render_many(hits.hits, SensorView, "source.json")
    }
  end

  def render("source.json", %{sensor: %{_source: hits}}) do
    %{
      id: hits.id,
      name: hits.name,
      metadata: render_many(hits.metadata, SensorView, "metadata.json"),
      slug: hits.slug,
      uuid: hits.uuid,
      project_id: hits.project_id,
      org_id: hits.org_id,
      gateway_id: hits.gateway_id,
      parent_id: hits.parent_id,
      parent_type: hits.parent_type,
      sensor_type_id: hits.sensor_type_id
    }
  end
end
