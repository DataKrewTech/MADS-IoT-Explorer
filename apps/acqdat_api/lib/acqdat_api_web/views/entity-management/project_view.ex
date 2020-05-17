defmodule AcqdatApiWeb.EntityManagement.ProjectView do
  use AcqdatApiWeb, :view
  alias AcqdatApiWeb.EntityManagement.AssetView
  alias AcqdatApiWeb.EntityManagement.SensorView

  def render("project.json", %{project: project}) do
    params =
      render_many(project.sensors, SensorView, "sensor_tree.json") ++
        render_many(project.assets, AssetView, "asset_tree.json")

    %{
      type: "Project",
      id: project.id,
      name: project.name,
      archived: project.archived,
      slug: project.slug,
      description: project.description,
      version: project.version,
      entities: params
    }
  end
end
