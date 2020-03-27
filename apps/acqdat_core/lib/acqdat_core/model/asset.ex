defmodule AcqdatCore.Model.Asset do
  import Ecto.Query
  import AsNestedSet.Queriable, only: [dump_one: 2]
  alias AcqdatCore.Model.Sensor, as: SensorModel
  alias AcqdatCore.Schema.Asset
  alias AcqdatCore.Repo

  def child_assets(org_id) do
    org_assets = fetch_root_assets(org_id)

    org_assets =
      Enum.reduce(org_assets, [], fn asset, acc ->
        entities =
          AsNestedSet.descendants(asset)
          |> AsNestedSet.execute(Repo)

        res_asset = fetch_child_sensors(List.first(entities), entities, asset)
        acc = acc ++ [res_asset]
      end)
  end

  defp fetch_child_sensors(nil, _entities, asset) do
    sensors = SensorModel.child_sensors(asset)
    Map.put_new(asset, :sensors, sensors)
  end

  defp fetch_child_sensors(_data, entities, asset) do
    entities_with_sensors =
      Enum.reduce(entities, [], fn asset, acc_sensor ->
        entities = SensorModel.child_sensors(asset)
        asset = Map.put_new(asset, :sensors, entities)
        acc_sensor = acc_sensor ++ [asset]
      end)

    Map.put_new(asset, :assets, entities_with_sensors)
  end

  defp fetch_root_assets(org_id) do
    query =
      from(asset in Asset,
        where: asset.org_id == ^org_id and is_nil(asset.parent_id) == true
      )

    Repo.all(query)
  end
end
