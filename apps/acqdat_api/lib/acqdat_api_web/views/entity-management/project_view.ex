defmodule AcqdatApiWeb.EntityManagement.ProjectView do
  use AcqdatApiWeb, :view
  alias AcqdatApiWeb.EntityManagement.AssetView
  alias AcqdatApiWeb.EntityManagement.SensorView
  alias AcqdatApiWeb.EntityManagement.ProjectView
  alias AcqdatApi.ElasticSearch
  alias AcqdatCore.Model.EntityManagement.Project

  def render("project.json", %{project: project}) do
    params =
      render_many(project.sensors, SensorView, "sensor_tree.json") ++
        render_many(project.assets, AssetView, "asset_tree.json")

    %{
      type: "Project",
      id: project.id,
      name: project.name,
      archived: project.archived,
      slug: project.slug,
      description: project.description,
      version: project.version,
      entities: params
    }
  end

  def render("project_including_gateway.json", %{project: project}) do
    params =
      render_many(project.sensors, SensorView, "sensor_hierarchy_tree.json") ++
        render_many(project.assets, AssetView, "asset_tree_with_gateway.json")

    %{
      type: "Project",
      id: project.id,
      name: project.name,
      archived: project.archived,
      slug: project.slug,
      description: project.description,
      version: project.version,
      entities: params
    }
  end

  def render("index.json", project) do
    %{
      projects: render_many(project.entries, ProjectView, "project_index.json"),
      page_number: project.page_number,
      page_size: project.page_size,
      total_entries: project.total_entries,
      total_pages: project.total_pages
    }
  end

  def render("user_list.json", %{users: users}) do
    %{users: render_many(users, ProjectView, "user_details.json")}
  end

  def render("user_details.json", %{project: user_details}) do
    %{
      id: user_details.id,
      email: user_details.email,
      first_name: user_details.first_name,
      last_name: user_details.last_name,
      image: user_details.avatar,
      role_id: user_details.role_id
    }
  end

  def render("show.json", %{project: project}) do
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
      metadata: render_many(project.metadata, ProjectView, "metadata.json"),
      start_date: project.start_date,
      creator_id: project.creator_id,
      leads: render_many(project.leads, ProjectView, "user.json"),
      users: render_many(project.users, ProjectView, "user.json")
    }
  end

  def render("project_index.json", %{project: project}) do
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
      metadata: render_many(project.metadata, ProjectView, "metadata.json"),
      start_date: project.start_date,
      creator_id: project.creator_id,
      creator: render_one(project.creator, ProjectView, "user.json"),
      created_at: project.inserted_at,
      leads: render_many(project.leads, ProjectView, "user.json"),
      users: render_many(project.users, ProjectView, "user.json")
    }
  end

  def render("project_gateway.json", %{project: project}) do
    %{
      type: "Project",
      id: project.id,
      name: project.name,
      archived: project.archived,
      slug: project.slug,
      description: project.description,
      version: project.version
    }
  end

  def render("user.json", %{project: user}) do
    %{
      id: user.id,
      first_name: user.first_name,
      last_name: user.last_name,
      email: user.email,
      org_id: user.org_id,
      role_id: user.role_id
    }
  end

  def render("metadata.json", %{project: parameter}) do
    %{
      id: parameter.id,
      name: parameter.name,
      data_type: parameter.data_type,
      unit: parameter.unit,
      value: parameter.value,
      uuid: parameter.uuid
    }
  end

  def render("hits.json", %{hits: hits}) do
    %{
      projects: render_many(hits.hits, ProjectView, "source.json"),
      total_entries: ElasticSearch.find_total_counts("org")
    }
  end

  def render("source.json", %{project: %{_source: hits}}) do
    project = Project.get_for_view(hits.id)

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
      metadata: render_many(project.metadata, ProjectView, "metadata.json"),
      start_date: project.start_date,
      creator_id: project.creator_id,
      creator: render_one(project.creator, ProjectView, "user.json"),
      created_at: project.inserted_at,
      leads: render_many(project.leads, ProjectView, "user.json"),
      users: render_many(project.users, ProjectView, "user.json")
    }
  end
end
