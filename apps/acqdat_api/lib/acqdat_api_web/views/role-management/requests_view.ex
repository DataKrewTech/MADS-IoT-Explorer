defmodule AcqdatApiWeb.RoleManagement.RequestsView do
  use AcqdatApiWeb, :view

  def render("request_messg.json", %{message: message}) do
    %{
      status: message
    }
  end
end
