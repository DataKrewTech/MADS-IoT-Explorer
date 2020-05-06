defmodule EntityParser do
  alias AcqdatCore.Model.Sensor, as: SensorModel
  alias AcqdatCore.Model.Asset, as: AssetModel
  import AsNestedSet.Queriable, only: [dump_one: 2]
  
  def parse(entities, org_id, parent_id, parent_type) do
    if entities !== nil do
      for entity <- entities do
          parent_entity = case {entity["type"], entity["action"]} do
            {"Asset", "create"} ->
              asset_creation(entity, org_id, parent_id, parent_type)
            {"Asset", "update"} ->
              asset_updation(entity, org_id)
            {"Asset", "delete"} ->
              asset_deletion(entity)
            {"Asset", nil} ->
              nil
            {"Sensor", "create"} ->
              sensor_creation(entity, org_id, parent_id, parent_type)
            {"Sensor", "update"}  ->
              sensor_updation(entity, org_id)
            {"Sensor", "delete"} ->
              sensor_deletion(entity)
            {"Sensor", nil} ->
              nil
            {"Parameter", _} ->
              nil          end
          parse(entity["entities"], org_id, entity["id"], entity["type"])
      end
    end
  end

  defp asset_creation(entity, org_id, parent_id, parent_type) do
    IO.puts("inside asset_creation")
    parent_asset = case {parent_type, parent_id} do
      {"Organisation", nil} ->
        add_asset_as_root(entity, org_id)
      {"Asset", _} ->
        add_asset_as_child(entity, org_id, parent_id)
    end
    parent_asset
  end

  defp add_asset_as_root(%{"name" => name}, org_id) do
    AssetModel.add_as_root(%{name: name, org_id: org_id})
  end

  # defp add_asset_as_child(%{"name" => name}, org_id, parent_id) do
  #   AssetModel.add_asset_as_child(parent_entity, name, org_id, :child)
  # end

  defp add_asset_as_child(%{"name" => name}, org_id, parent_id) do
    {:ok, parent_entity} = AssetModel.get(parent_id)
    #AcqdatCore.Model.Asset.add_asset_as_child(nil, "Common Space 34535", 1, :child)
    AssetModel.add_as_child(parent_entity, name, org_id, :child)
  end

  defp asset_updation(entity, org_id) do
    IO.puts("inside asset_updation")
    nil
  end

  defp asset_deletion(%{"id" => id}) do
    IO.puts("inside asset_deletion")
    {:ok, asset} = AssetModel.get(id)
    AssetModel.delete(asset)
    nil
  end

  defp sensor_creation(%{"name" => name}, org_id, parent_id, parent_type) do
    IO.puts("inside sensor_creation")
    IO.puts(parent_id)
    SensorModel.create(%{
      name: name,
      parent_id: parent_id,
      parent_type: parent_type,
      org_id: org_id
    })
    nil
  end

  defp sensor_updation(%{"id" => id, "name" => name, "parent_id" => parent_id, "parent_type" => parent_type}, org_id) do
    IO.puts("inside sensor_updation")
    {:ok, sensor} = SensorModel.get(id)
    SensorModel.update(sensor, %{
      name: name,
      parent_id: parent_id,
      parent_type: parent_type
    })
    nil
  end

  defp sensor_deletion(%{"id" => id}) do
    IO.puts("inside sensor_deletion")
    SensorModel.delete(id)
    nil
  end
end