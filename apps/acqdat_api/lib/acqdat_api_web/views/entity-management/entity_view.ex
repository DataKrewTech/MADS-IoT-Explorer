defmodule AcqdatApiWeb.EntityManagement.EntityView do
  use AcqdatApiWeb, :view
  alias AcqdatApiWeb.EntityManagement.ProjectView
  alias AcqdatApiWeb.IotManager.GatewayView

  def render("organisation_tree.json", %{org: org}) do
    %{
      type: "Organisation",
      id: org.id,
      name: org.name,
      entities: render_many(org.project_data, ProjectView, "project.json"),
      gateways: render_many(org.gateway_data, GatewayView, "gateway.json")
    }
  end
end
