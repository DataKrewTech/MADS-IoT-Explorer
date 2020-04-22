defmodule AcqdatApiWeb.OrganisationView do
  use AcqdatApiWeb, :view
  alias AcqdatApiWeb.AssetView

  def render("organisation_tree.json", %{org: org}) do
    %{
      type: "Organisation",
      id: org.id,
      name: org.name,
      entities: render_many(org.assets, AssetView, "asset_tree.json")
    }
  end

  def render("org.json", %{organisation: org}) do
    %{
      type: "Organisation",
      id: org.id,
      name: org.name
    }
  end
end
