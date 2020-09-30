defmodule AcqdatApiWeb.DataInsights.TopologyView do
  use AcqdatApiWeb, :view
  alias AcqdatApiWeb.DataInsights.TopologyView
  alias AcqdatApiWeb.EntityManagement.{AssetTypeView, SensorTypeView}

  def render("index.json", %{topology: topology}) do
    %{
      topology: render_many(topology, TopologyView, "topology_data.json")
    }
  end

  def render("details.json", %{topology: topology}) do
    %{
      entities: render_many(topology, TopologyView, "entity.json")
    }
  end

  def render("entity.json", %{
        topology: %AcqdatCore.Schema.EntityManagement.AssetType{} = entity
      }) do
    %{
      id: entity.id,
      name: entity.name,
      type: "AssetType",
      parameters: render_many(entity.parameters, AssetTypeView, "data_tree.json"),
      metadata: render_many(entity.metadata, AssetTypeView, "metadata.json")
    }
  end

  def render("entity.json", %{
        topology: %AcqdatCore.Schema.EntityManagement.SensorType{} = entity
      }) do
    %{
      id: entity.id,
      name: entity.name,
      type: "SensorType",
      parameters: render_many(entity.parameters, AssetTypeView, "data_tree.json"),
      metadata: render_many(entity.metadata, AssetTypeView, "metadata.json")
    }
  end

  def render("topology_data.json", %{topology: data}) do
    %{
      entities: render_many(data, TopologyView, "asset_type1.json")
    }
  end

  def render("asset_type1.json", %{
        topology: {%AcqdatCore.Schema.EntityManagement.AssetType{} = entity, value}
      }) do
    entities =
      if value == [%{}], do: [], else: render_many(value, TopologyView, "topology_data.json")

    %{
      id: entity.id,
      name: entity.name,
      type: "AssetType",
      parameters: render_many(entity.parameters, AssetTypeView, "data_tree.json"),
      metadata: render_many(entity.metadata, AssetTypeView, "metadata.json"),
      entities: entities
    }
  end

  def render("asset_type1.json", %{
        topology: {%AcqdatCore.Schema.EntityManagement.SensorType{} = entity, value}
      }) do
    %{
      id: entity.id,
      name: entity.name,
      parameters: render_many(entity.parameters, SensorTypeView, "data_tree.json"),
      metadata: render_many(entity.metadata, SensorTypeView, "metadata.json"),
      type: "SensorType"
    }
  end
end
