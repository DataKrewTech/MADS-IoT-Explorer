defmodule AcqdatApiWeb.SensorTypeView do
  use AcqdatApiWeb, :view
  alias AcqdatApiWeb.ErrorView
  alias AcqdatApiWeb.SensorTypeView

  def render("sensor_type.json", %{sensor_type: sensor_type}) do
    %{
      id: sensor_type.id,
      name: sensor_type.name,
      make: sensor_type.make,
      identifier: sensor_type.identifier
    }
  end

  def render("sensor_type_with_value_keys.json", %{sensor_type: sensor_type}) do
    %{
      id: sensor_type.id,
      name: sensor_type.name,
      make: sensor_type.make,
      identifier: sensor_type.identifier,
      value_keys: sensor_type.value_keys
    }
  end

  def render("index.json", sensor_types) do
    %{
      sensor_types: render_many(sensor_types.entries, SensorTypeView, "sensor_type.json"),
      page_number: sensor_types.page_number,
      page_size: sensor_types.page_size,
      total_entries: sensor_types.total_entries,
      total_pages: sensor_types.total_pages
    }
  end

  def render("400.json", assigns) do
    ErrorView.render("400.json", assigns)
  end

  def render("404.json", assigns) do
    ErrorView.render("404.json", assigns)
  end
end
