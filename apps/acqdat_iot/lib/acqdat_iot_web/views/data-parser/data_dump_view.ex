defmodule AcqdatIotWeb.DataParser.DataDumpView do
  use AcqdatApiWeb, :view
  alias AcqdatIotWeb.DataParser.DataDumpView

  def render("index.json", data_dump) do
    %{
      data_dumps: render_many(data_dump.entries, DataDumpView, "show.json"),
      page_number: data_dump.page_number,
      page_size: data_dump.page_size,
      total_entries: data_dump.total_entries,
      total_pages: data_dump.total_pages
    }
  end

  def render("show.json", %{data_dump: data_dump}) do
    %{
      data: data_dump.data,
      gateway_id: data_dump.gateway_id,
      inserted_timestamp: data_dump.inserted_timestamp
    }
  end
end
