defmodule AcqdatApiWeb.EntityManagement.AssetView do
  use AcqdatApiWeb, :view
  alias AcqdatApiWeb.EntityManagement.AssetView
  alias AcqdatApiWeb.EntityManagement.SensorView

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
end
