defmodule AcqdatApiWeb.EntityManagement.SensorTypeView do
  use AcqdatApiWeb, :view
  alias AcqdatApiWeb.SensorTypeView
  alias AcqdatApiWeb.OrganisationView

  def render("sensor_type.json", %{sensor_type: sensor_type}) do
    %{
      id: sensor_type.id,
      name: sensor_type.name,
      description: sensor_type.description,
      metadata: render_many(sensor_type.metadata, SensorTypeView, "metadata.json"),
      org_id: sensor_type.org_id,
      slug: sensor_type.slug,
      uuid: sensor_type.uuid,
      parameters: render_many(sensor_type.parameters, SensorTypeView, "data_tree.json"),
      org: render_one(sensor_type.org, OrganisationView, "org.json")
    }
  end

  def render("data_tree.json", %{sensor_type: parameter}) do
    %{
      id: parameter.id,
      name: parameter.name,
      data_type: parameter.data_type,
      unit: parameter.unit,
      uuid: parameter.uuid
    }
  end

  def render("metadata.json", %{sensor_type: parameter}) do
    %{
      id: parameter.id,
      name: parameter.name,
      type: parameter.type,
      unit: parameter.unit
    }
  end

  def render("index.json", sensor_type) do
    %{
      sensors_type: render_many(sensor_type.entries, SensorTypeView, "sensor_type.json"),
      page_number: sensor_type.page_number,
      page_size: sensor_type.page_size,
      total_entries: sensor_type.total_entries,
      total_pages: sensor_type.total_pages
    }
  end
end
