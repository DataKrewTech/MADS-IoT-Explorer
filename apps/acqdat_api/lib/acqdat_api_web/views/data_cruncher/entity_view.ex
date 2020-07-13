defmodule AcqdatApiWeb.DataCruncher.EntityView do
  use AcqdatApiWeb, :view
  alias AcqdatApiWeb.DataCruncher.EntityView

  def render("organisation_tree.json", %{org: org}) do
    %{
      type: "Organisation",
      id: org.id,
      name: org.name,
      entities: render_many(org.project_data, EntityView, "project.json")
    }
  end

  def render("project.json", %{entity: project}) do
    params =
      render_many(project.sensors, EntityView, "sensor_tree.json") ++
        render_many(project.assets, EntityView, "asset_tree.json")

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

  def render("asset_tree.json", %{entity: asset}) do
    assets =
      if Map.has_key?(asset, :assets) do
        render_many(asset.assets, EntityView, "asset_tree.json")
      end

    sensors =
      if Map.has_key?(asset, :sensors) do
        render_many(asset.sensors, EntityView, "sensor_tree.json")
      end

    %{
      type: "Asset",
      id: asset.id,
      parent_id: asset.parent_id,
      name: asset.name,
      properties: asset.properties,
      type: "Asset",
      id: asset.id,
      name: asset.name,
      description: asset.description,
      properties: asset.properties,
      parent_id: asset.parent_id,
      asset_type_id: asset.asset_type_id,
      creator_id: asset.creator_id,
      entities: (assets || []) ++ (sensors || [])
    }
  end

  def render("sensor_tree.json", %{entity: sensor}) do
    %{
      type: "Sensor",
      id: sensor.id,
      parent_id: sensor.parent_id,
      parent_type: sensor.parent_type,
      sensor_type_id: sensor.sensor_type_id,
      name: sensor.name,
      sensor_type: render_one(sensor.sensor_type, EntityView, "sensor_type.json"),
      metadata: render_many(sensor.metadata, EntityView, "metadata.json"),
      entities: render_many(sensor.sensor_type.parameters, EntityView, "parameters.json")
    }
  end

  def render("parameters.json", %{entity: parameter}) do
    %{
      id: parameter.id,
      name: parameter.name,
      data_type: parameter.data_type,
      unit: parameter.unit,
      uuid: parameter.uuid,
      type: "SensorParameter"
    }
  end

  def render("sensor_type.json", %{entity: sensor_type}) do
    %{
      id: sensor_type.id,
      name: sensor_type.name,
      description: sensor_type.description,
      org_id: sensor_type.org_id,
      slug: sensor_type.slug,
      uuid: sensor_type.uuid,
      generated_by: sensor_type.generated_by,
      project_id: sensor_type.project_id
    }
  end

  def render("metadata.json", %{entity: metadata}) do
    %{
      id: metadata.id,
      name: metadata.name,
      data_type: metadata.data_type,
      unit: metadata.unit,
      uuid: metadata.uuid,
      value: metadata.value
    }
  end
end
