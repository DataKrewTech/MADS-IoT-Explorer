defmodule AcqdatApiWeb.AppView do
  use AcqdatApiWeb, :view
  alias AcqdatApiWeb.AppView

  def render("app.json", %{app: app}) do
    %{
      id: app.id,
      name: app.name,
      description: app.description,
      icon_id: app.icon_id,
      category: app.category,
      backward_compatibility: app.compatibility,
      copyright: app.copyright,
      key: app.key
    }
  end

  def render("index.json", apps) do
    %{
      apps: render_many(apps.entries, AppView, "app.json")
    }
  end
end
