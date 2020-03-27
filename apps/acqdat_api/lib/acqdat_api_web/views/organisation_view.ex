defmodule AcqdatApiWeb.OrganisationView do
  use AcqdatApiWeb, :view
  alias AcqdatApiWeb.AssetView
  alias AcqdatApiWeb.SensorView

  def render("organisation_tree.json", %{org: org}) do
    %{
      type: "Organisation",
      # description: org.description,
      id: org.id,
      # inserted_at: org.inserted_at,
      # metadata: org.metadata,
      name: org.name,
      # updated_at: org.updated_at,
      # uuid: org.uuid,
      entities: render_many(org.assets, AssetView, "asset_tree.json")
    }
  end
end
