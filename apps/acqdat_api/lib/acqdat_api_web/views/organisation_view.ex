defmodule AcqdatApiWeb.OrganisationView do
  use AcqdatApiWeb, :view
  alias AcqdatApiWeb.AssetView
  alias AcqdatApiWeb.SensorView

  def render("organisation_tree.json", %{org: org}) do
    %{
      type: "Organisation",
      id: org.id,
      name: org.name,
      entities: render_many(org.assets, AssetView, "asset_tree.json")
    }
  end
end
