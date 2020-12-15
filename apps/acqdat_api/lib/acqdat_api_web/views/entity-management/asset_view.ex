defmodule AcqdatApiWeb.EntityManagement.AssetView do
  use AcqdatApiWeb, :view
  alias AcqdatApiWeb.EntityManagement.{AssetView, AssetTypeView, SensorView}
  alias AcqdatApiWeb.IotManager.GatewayView
  alias AcqdatCore.Model.EntityManagement.Asset, as: AssetModel
  alias AcqdatApi.ElasticSearch

  def render("asset_tree.json", %{asset: asset}) do
    assets =
      if Map.has_key?(asset, :assets) do
        render_many(asset.assets, AssetView, "asset_tree.json")
      end

    sensors =
      if Map.has_key?(asset, :sensors) do
        render_many(asset.sensors, SensorView, "sensor_tree.json")
      end

    entities = (assets || []) ++ (sensors || [])

    view_helper(asset) |> Map.put_new(:entities, entities)
  end

  def render("asset_tree_with_gateway.json", %{asset: asset}) do
    assets =
      if Map.has_key?(asset, :assets) do
        render_many(asset.assets, AssetView, "asset_tree_with_gateway.json")
      end

    sensors =
      if Map.has_key?(asset, :sensors) do
        render_many(asset.sensors, SensorView, "sensor_hierarchy_tree.json")
      end

    gateways =
      if Map.has_key?(asset, :gateways) do
        render_many(asset.gateways, GatewayView, "gateway_tree.json")
      end

    entities = (assets || []) ++ (sensors || []) ++ (gateways || [])

    view_helper(asset) |> Map.put_new(:entities, entities)
  end

  def render("asset.json", %{asset: asset}) do
    %{
      type: "Asset",
      id: asset.id,
      name: asset.name,
      description: asset.description,
      properties: asset.properties,
      parent_id: asset.parent_id,
      asset_type_id: asset.asset_type_id,
      creator_id: asset.creator_id,
      metadata: render_many(asset.metadata, AssetView, "metadata.json")
    }
  end

  def render("metadata.json", %{asset: metadata}) do
    %{
      id: metadata.id,
      name: metadata.name,
      data_type: metadata.data_type,
      unit: metadata.unit,
      uuid: metadata.uuid,
      value: metadata.value
    }
  end

  def render("hits.json", %{hits: hits}) do
    %{
      assets: render_many(hits.hits, AssetView, "source.json"),
      total_entries: length(hits.hits)
    }
  end

  def render("source.json", %{asset: %{_source: hits}}) do
    asset = AssetModel.get_for_view(hits.id)

    %{
      type: "Asset",
      id: asset.id,
      name: asset.name,
      properties: asset.properties,
      description: asset.description,
      parent_id: asset.parent_id,
      asset_type_id: asset.asset_type_id,
      creator_id: asset.creator_id,
      metadata: render_many(asset.metadata, AssetView, "metadata.json"),
      asset_type: render_one(asset.asset_type, AssetTypeView, "asset_type.json")
    }
  end

  def render("index.json", asset) do
    %{
      assets: render_many(asset.entries, AssetView, "asset.json"),
      page_number: asset.page_number,
      page_size: asset.page_size,
      total_entries: asset.total_entries,
      total_pages: asset.total_pages
    }
  end

  defp view_helper(asset) do
    asset_mapped_parameters =
      if Map.has_key?(asset, :sensors) do
        AssetModel.fetch_mapped_parameters(asset)
      end

    %{
      type: "Asset",
      id: asset.id,
      name: asset.name,
      properties: asset.properties,
      description: asset.description,
      parent_id: asset.parent_id,
      asset_type_id: asset.asset_type_id,
      creator_id: asset.creator_id,
      metadata: render_many(asset.metadata, AssetView, "metadata.json"),
      mapped_parameters: asset_mapped_parameters,
      asset_type: render_one(asset.asset_type, AssetTypeView, "asset_type.json")
    }
  end
end
