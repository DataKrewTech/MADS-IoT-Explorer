defmodule AcqdatApiWeb.EntityManagement.AssetTypeView do
  use AcqdatApiWeb, :view
  alias AcqdatApiWeb.EntityManagement.AssetTypeView
  # alias AcqdatApiWeb.EntityManagement.OrganisationView

  def render("asset_type.json", %{asset_type: asset_type}) do
    %{
      id: asset_type.id,
      name: asset_type.name,
      description: asset_type.description,
      metadata: render_many(asset_type.metadata, AssetTypeView, "metadata.json"),
      org_id: asset_type.org_id,
      slug: asset_type.slug,
      uuid: asset_type.uuid,
      project_id: asset_type.project_id,
      sensor_type_present: asset_type.sensor_type_present,
      sensor_type_uuid: asset_type.sensor_type_uuid,
      parameters: render_many(asset_type.parameters, AssetTypeView, "data_tree.json")
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

  def render("index.json", asset_type) do
    %{
      asset_types: render_many(asset_type.entries, AssetTypeView, "asset_type.json"),
      page_number: asset_type.page_number,
      page_size: asset_type.page_size,
      total_entries: asset_type.total_entries,
      total_pages: asset_type.total_pages
    }
  end
end
