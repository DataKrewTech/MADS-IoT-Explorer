defmodule AcqdatApiWeb.DataInsights.TopologyView do
  use AcqdatApiWeb, :view
  alias AcqdatApiWeb.DataInsights.TopologyView
  alias AcqdatApiWeb.EntityManagement.{AssetTypeView, SensorTypeView}
  alias AcqdatCore.ElasticSearch
  alias AcqdatCore.Model.EntityManagement.Project

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

  def render("hits.json", %{hits: hits}) do
    project_ids = extract_ids(hits.hits)
    projects = Project.get_for_view(project_ids)

    %{
      projects: render_many(projects, ProjectView, "source.json"),
      total_entries: hits.total.value
    }
  end

  def render("source.json", %{topology: project}) do
    %{
      type: "Project",
      id: project.id,
      name: project.name,
      archived: project.archived,
      slug: project.slug,
      description: project.description,
      version: project.version,
      location: project.location,
      org_id: project.org_id,
      avatar: project.avatar,
      start_date: project.start_date,
      creator_id: project.creator_id,
      created_at: project.inserted_at
    }
  end

  defp extract_ids(hits) do
    Enum.reduce(hits, [], fn %{_source: hits}, acc ->
      acc ++ [hits.id]
    end)
  end
end
