defmodule AcqdatCore.Seed.DataFeeder.Sensor do
  alias AcqdatCore.Schema.EntityManagement.Sensor
  alias AcqdatCore.Schema.EntityManagement.AssetType
  alias AcqdatCore.Schema.EntityManagement.SensorType
  alias AcqdatCore.Schema.EntityManagement.Asset

  alias AcqdatCore.Repo
  import Tirexs.HTTP

  def seed_data!() do
    sensors = Repo.all(Sensor)
    Enum.each(sensors, fn sensor ->
      insert_sensor("sensors", sensor)
    end)
    assets = Repo.all(Asset)
    Enum.each(assets, fn asset ->
      insert_asset("assets", asset)
    end)
    asset_types = Repo.all(AssetType)
    Enum.each(asset_types, fn asset_type ->
      insert_asset_type("asset_types", asset_type)
    end)
    sensor_types = Repo.all(SensorType)
    Enum.each(sensor_types, fn sensor_type ->
      insert_sensor_type("sensor_types", sensor_type)
    end)
  end

  def insert_asset(type, params) do
    post("#{type}/_doc/#{params.id}?refresh=true",
      id: params.id,
      name: params.name,
      properties: params.properties,
      slug: params.slug,
      uuid: params.uuid,
      project_id: params.project_id,
      inserted_at: DateTime.to_unix(params.inserted_at)
    )
  end

  defp insert_sensor(type, params) do
    post("#{type}/_doc/#{params.id}?refresh=true",
      id: params.id,
      name: params.name,
      metadata: params.metadata,
      slug: params.slug,
      uuid: params.uuid,
      project_id: params.project_id,
      org_id: params.org_id,
      gateway_id: params.gateway_id,
      parent_id: params.parent_id,
      parent_type: params.parent_type,
      description: params.description,
      sensor_type_id: params.sensor_type_id,
      inserted_at: DateTime.to_unix(params.inserted_at)
      )
  end

  defp insert_asset_type(type, params) do
    post("#{type}/_doc/#{params.id}?refresh=true",
      id: params.id,
      name: params.name,
      slug: params.slug,
      uuid: params.uuid,
      project_id: params.project_id,
      org_id: params.org_id,
      description: params.description,
      sensor_type_present: params.sensor_type_present,
      sensor_type_uuid: params.sensor_type_uuid,
      metadata: params.metadata,
      parameters: params.parameters,
      inserted_at: DateTime.to_unix(params.inserted_at)
      )
  end

  defp insert_sensor_type(type, params) do
    post("#{type}/_doc/#{params.id}?refresh=true",
      id: params.id,
      name: params.name,
      slug: params.slug,
      uuid: params.uuid,
      project_id: params.project_id,
      description: params.description,
      org_id: params.org_id,
      generated_by: params.generated_by,
      metadata: params.metadata,
      parameters: params.parameters,
      inserted_at: DateTime.to_unix(params.inserted_at)
      )
  end
end
