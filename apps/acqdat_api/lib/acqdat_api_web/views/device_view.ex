defmodule AcqdatApiWeb.DeviceView do
  use AcqdatApiWeb, :view
  alias AcqdatApiWeb.DeviceView

  def render("device.json", %{device: device}) do
    %{
      id: device.id,
      name: device.name,
      uuid: device.uuid,
      description: device.description,
      access_token: device.access_token
    }
  end

  def render("index.json", device) do
    %{
      devices: render_many(device.entries, DeviceView, "device.json"),
      page_number: device.page_number,
      page_size: device.page_size,
      total_entries: device.total_entries,
      total_pages: device.total_pages
    }
  end
end
