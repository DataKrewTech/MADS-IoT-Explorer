defmodule AcqdatApiWeb.ProjectView do
  use AcqdatApiWeb, :view
  alias AcqdatApiWeb.AssetView

  def render("project.json", %{project: project}) do
    %{
      type: "Project",
      id: project.id,
      name: project.name,
      archived: project.archived,
      slug: project.slug,
      description: project.description,
      version: project.version,
      entities: render_many(project.assets, AssetView, "asset_tree.json")
    }
  end
end
