defmodule AcqdatApiWeb.DataInsights.TopologyView do
  use AcqdatApiWeb, :view
  alias AcqdatApiWeb.DataInsights.TopologyView
  alias AcqdatApiWeb.EntityManagement.{AssetTypeView, SensorTypeView}

  def render("index.json", %{topology: topology}) do
    %{
      id: topology.id,
      name: topology.name,
      type: topology.type,
      children: render_many(topology[:children] || [], TopologyView, "topology_entity.json")
    }
  end

  def render("topology_entity.json", %{topology: topology}) do
    %{
      id: topology.id,
      name: topology.name,
      type: topology.type,
      children: render_many(topology[:children] || [], TopologyView, "topology_entity.json")
    }
  end

  def render("details.json", %{topology: topology}) do
    %{
      asset_types: render_many(topology[:asset_types], TopologyView, "asset_type.json"),
      sensor_types: render_many(topology[:sensor_types], TopologyView, "sensor_type.json")
    }
  end

  def render("asset_type.json", %{topology: entity}) do
    %{
      id: entity.id,
      name: entity.name,
      type: "AssetType",
      metadata: render_many(entity.metadata, AssetTypeView, "metadata.json")
    }
  end

  def render("sensor_type.json", %{
        topology: entity
      }) do
    %{
      id: entity.id,
      name: entity.name,
      type: "SensorType",
      parameters: render_many(entity.parameters, AssetTypeView, "data_tree.json"),
      metadata: render_many(entity.metadata, AssetTypeView, "metadata.json")
    }
  end
end
