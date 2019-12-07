defmodule AcqdatCore.Model.Helper do
  @moduledoc """
  Helper functions which can be used at multiple locations
  """

  def paginated_response(data, pagination_data) do
    %{
      entries: data,
      page_number: pagination_data.page_number,
      page_size: pagination_data.page_size,
      total_entries: pagination_data.total_entries,
      total_pages: pagination_data.total_pages
    }
  end
end
