defmodule AcqdatApiWeb.RoleManagement.RequestsView do
  use AcqdatApiWeb, :view
  alias AcqdatApiWeb.RoleManagement.RequestsView

  def render("request_messg.json", %{message: message}) do
    %{
      status: message
    }
  end

  def render("index.json", request) do
    %{
      requests: render_many(request.entries, RequestsView, "request.json"),
      page_number: request.page_number,
      page_size: request.page_size,
      total_entries: request.total_entries,
      total_pages: request.total_pages
    }
  end

  def render("request.json", %{requests: request}) do
    %{
      id: request.id,
      email: request.email,
      org_name: request.org_name,
      org_url: request.org_url,
      first_name: request.first_name,
      last_name: request.last_name,
      phone_number: request.phone_number,
      status: request.status,
      user_metadata: request.user_metadata
    }
  end
end
