defmodule AcqdatApiWeb.IotManager.GatewayView do
  use AcqdatApiWeb, :view
  alias AcqdatApiWeb.EntityManagement.OrganisationView
  alias AcqdatApiWeb.EntityManagement.ProjectView
  alias AcqdatApiWeb.IotManager.GatewayView
  alias AcqdatApiWeb.EntityManagement.SensorView
  alias AcqdatCore.Repo

  def render("index.json", gateway) do
    %{
      gateways: render_many(gateway.entries, GatewayView, "show.json"),
      page_number: gateway.page_number,
      page_size: gateway.page_size,
      total_entries: gateway.total_entries,
      total_pages: gateway.total_pages
    }
  end

  def render("organisation_tree.json", %{org: org}) do
    %{
      type: "Organisation",
      id: org.id,
      name: org.name,
      entities: render_many(org.project_data, ProjectView, "project.json"),
      gateways: render_many(org.gateway_data, GatewayView, "gateway.json")
    }
  end

  def render("show.json", %{gateway: gateway}) do
    %{
      type: "Gateway",
      id: gateway.id,
      name: gateway.name,
      access_token: gateway.access_token,
      serializer: gateway.serializer,
      channel: gateway.channel,
      parent_id: gateway.parent_id,
      parent_type: gateway.parent_type,
      slug: gateway.slug,
      description: gateway.description,
      static_data: render_many(gateway.static_data, GatewayView, "data.json"),
      streaming_data: render_many(gateway.streaming_data, GatewayView, "data.json"),
      current_location: gateway.current_location,
      org_id: gateway.org_id,
      image_url: gateway.image_url,
      org: render_one(gateway.org, OrganisationView, "org.json"),
      project: render_one(gateway.project, ProjectView, "project_gateway.json")
    }
  end

  def render("delete.json", %{gateway: gateway}) do
    %{
      type: "Gateway",
      id: gateway.id,
      name: gateway.name,
      access_token: gateway.access_token,
      serializer: gateway.serializer,
      channel: gateway.channel,
      parent_id: gateway.parent_id,
      parent_type: gateway.parent_type,
      slug: gateway.slug,
      description: gateway.description,
      static_data: render_many(gateway.static_data, GatewayView, "data.json"),
      streaming_data: render_many(gateway.streaming_data, GatewayView, "data.json"),
      current_location: gateway.current_location,
      org_id: gateway.org_id,
      image_url: gateway.image_url
    }
  end

  def render("data.json", %{gateway: data}) do
    %{
      data: data
    }
  end

  def render("gateway.json", %{gateway: gateway}) do
    gateway = Repo.preload(gateway, [:org, :project])

    %{
      type: "Gateway",
      id: gateway.id,
      name: gateway.name,
      access_token: gateway.access_token,
      serializer: gateway.serializer,
      channel: gateway.channel,
      parent_id: gateway.parent_id,
      parent_type: gateway.parent_type,
      slug: gateway.slug,
      description: gateway.description,
      static_data: render_many(gateway.static_data, GatewayView, "data.json"),
      streaming_data: render_many(gateway.streaming_data, GatewayView, "data.json"),
      current_location: gateway.current_location,
      org_id: gateway.org_id,
      image_url: gateway.image_url,
      org: render_one(gateway.org, OrganisationView, "org.json"),
      project: render_one(gateway.project, ProjectView, "project_gateway.json"),
      parent: render_one(gateway.parent, GatewayView, "parent.json"),
      childs: render_many(gateway.childs, SensorView, "sensor.json")
    }
  end

  def render("parent.json", %{gateway: parent}) do
    %{
      id: parent.id,
      name: parent.name,
      uuid: parent.uuid,
      slug: parent.slug
    }
  end

  def render("data_dump_index.json", data_dump) do
    %{
      data_dumps: render_many(data_dump.entries, GatewayView, "data_dump_show.json"),
      page_number: data_dump.page_number,
      page_size: data_dump.page_size,
      total_entries: data_dump.total_entries,
      total_pages: data_dump.total_pages
    }
  end

  def render("data_dump_show.json", %{gateway: data_dump}) do
    %{
      data: data_dump.data,
      gateway_id: data_dump.gateway_id,
      inserted_timestamp: data_dump.inserted_timestamp
    }
  end
end
