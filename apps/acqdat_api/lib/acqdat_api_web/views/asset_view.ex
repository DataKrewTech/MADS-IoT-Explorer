defmodule AcqdatApiWeb.AssetView do
  use AcqdatApiWeb, :view
  alias AcqdatApiWeb.AssetView
  alias AcqdatApiWeb.SensorView

  def render("asset_tree.json", %{asset: asset}) do
    params =
      with true <- Map.has_key?(asset, :assets) do
        render_many(asset.assets, AssetView, "asset_tree.json")
      else
        false ->
          render_many(asset.sensors, SensorView, "sensor_tree.json")
      end

    %{
      type: "Asset",
      id: asset.id,
      name: asset.name,
      properties: asset.properties,
      entities: params
      # TODO: Need to uncomment below fields depending on the future usecases in the view
      # description: asset.description,
      # image_url: asset.image_url,
      # inserted_at: asset.inserted_at,
      # mapped_parameters: asset.mapped_parameters,
      # metadata: asset.metadata,
      # slug: asset.slug,
      # updated_at: asset.updated_at,
      # uuid: asset.uuid,
    }
  end

  def render("asset.json", %{asset: asset}) do
    %{
      type: "Asset",
      id: asset.id,
      name: asset.name,
      properties: asset.properties,
      mapped_parameters: render_many(asset.mapped_parameters, AssetView, "parameters.json")
    }
  end

  def render("parameters.json", %{asset: asset}) do
    %{
      name: asset.name,
      uuid: asset.uuid,
      sensor_uuid: asset.sensor_uuid,
      parameter_uuid: asset.parameter_uuid
    }
  end

  def render("hits.json", %{hits: hits}) do
    %{
      assets: render_many(hits.hits, AssetView, "source.json")
    }
  end

  def render("source.json", %{asset: %{_source: hits}}) do
    %{
      id: hits.id,
      name: hits.name,
      properties: hits.properties,
      slug: hits.slug,
      uuid: hits.uuid
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
end
