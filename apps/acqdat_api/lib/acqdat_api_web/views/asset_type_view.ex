defmodule AcqdatApiWeb.AssetTypeView do
  use AcqdatApiWeb, :view
  alias AcqdatApiWeb.AssetTypeView
  alias AcqdatApiWeb.OrganisationView

  def render("asset_type.json", %{asset_type: asset_type}) do
    %{
      id: asset_type.id,
      name: asset_type.name,
      description: asset_type.description,
      metadata: render_many(asset_type.metadata, AssetTypeView, "metadata.json"),
      org_id: asset_type.org_id,
      slug: asset_type.slug,
      uuid: asset_type.uuid,
      sensor_type_present: asset_type.sensor_type_present,
      sensor_type_uuid: asset_type.sensor_type_uuid,
      parameters: render_many(asset_type.parameters, AssetTypeView, "data_tree.json"),
      org: render_one(asset_type.org, OrganisationView, "org.json")
    }
  end

  def render("data_tree.json", %{asset_type: parameter}) do
    %{
      id: parameter.id,
      name: parameter.name,
      data_type: parameter.data_type,
      unit: parameter.unit,
      uuid: parameter.uuid
    }
  end

  def render("metadata.json", %{asset_type: parameter}) do
    %{
      id: parameter.id,
      name: parameter.name,
      data_type: parameter.data_type,
      unit: parameter.unit,
      uuid: parameter.uuid
    }
  end
end
