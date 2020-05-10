defmodule AcqdatApi.EntityParser do
  alias AcqdatCore.Model.Sensor, as: SensorModel
  alias AcqdatCore.Model.Asset, as: AssetModel
  alias AcqdatCore.Model.Organisation, as: OrgModel

  # NOTE: EntityParser.parse(k["entities"], k["id"], nil, k["type"], nil)
  # TODO: Error handling to do
  def parse(entities, org_id, parent_id, parent_type, parent_entity) do
    if entities !== nil do
      for entity <- entities do
        result = entity_seggr(entity, org_id, parent_id, parent_type, parent_entity)

        case result do
          {:ok, parent_entity} ->
            parse(entity["entities"], org_id, entity["id"], entity["type"], parent_entity)

          nil ->
            parse(entity["entities"], org_id, entity["id"], entity["type"], nil)
        end
      end
    end

    {:ok, "success"}
  end

  def entity_seggr(
        %{"type" => type, "action" => action} = entity,
        org_id,
        parent_id,
        parent_type,
        parent_entity
      )
      when type == "Asset" and action == "create" do
    asset_creation(entity, org_id, parent_id, parent_type, parent_entity)
  end

  def entity_seggr(
        %{"type" => type, "action" => action} = entity,
        org_id,
        _parent_id,
        _parent_type,
        _parent_entity
      )
      when type == "Asset" and action == "update" do
    asset_updation(entity, org_id)
  end

  def entity_seggr(
        %{"type" => type, "action" => action} = entity,
        _org_id,
        _parent_id,
        _parent_type,
        _parent_entity
      )
      when type == "Asset" and action == "delete" do
    asset_deletion(entity)
  end

  def entity_seggr(
        %{"type" => type, "action" => action} = entity,
        org_id,
        parent_id,
        parent_type,
        parent_entity
      )
      when type == "Sensor" and action == "create" do
    sensor_creation(entity, org_id, parent_id, parent_type, parent_entity)
  end

  def entity_seggr(
        %{"type" => type, "action" => action} = entity,
        org_id,
        _parent_id,
        _parent_type,
        _parent_entity
      )
      when type == "Sensor" and action == "update" do
    sensor_updation(entity, org_id)
  end

  def entity_seggr(
        %{"type" => type, "action" => action} = entity,
        _org_id,
        _parent_id,
        _parent_type,
        _parent_entity
      )
      when type == "Sensor" and action == "delete" do
    sensor_deletion(entity)
  end

  def entity_seggr(%{"type" => type} = entity, _org_id, _parent_id, _parent_type, _parent_entity) do
    nil
  end

  defp asset_creation(entity, org_id, parent_id, parent_type, parent_entity) do
    parent_asset =
      case {parent_type, parent_id, parent_entity} do
        {"Organisation", nil, _} ->
          add_asset_as_root(entity, org_id)

        {"Asset", _, nil} ->
          add_asset_as_child(entity, org_id, parent_id)

        {"Asset", _, _} ->
          add_asset_as_child(entity, org_id, parent_entity.id)
      end

    parent_asset
  end

  defp add_asset_as_root(%{"name" => name}, org_id) do
    {:ok, org} = OrgModel.get_by_id(org_id)
    AssetModel.add_as_root(%{name: name, org_id: org_id, org_name: org.name})
  end

  defp add_asset_as_child(%{"name" => name}, org_id, parent_id) do
    {:ok, parent_entity} = AssetModel.get(parent_id)
    AssetModel.add_as_child(parent_entity, name, org_id, :child)
  end

  defp asset_updation(%{"id" => id, "name" => name}, org_id) do
    IO.puts("inside asset asset_updation")
    {:ok, asset} = AssetModel.get(id)

    AssetModel.update(asset, %{
      name: name
    })

    nil
  end

  defp asset_deletion(%{"id" => id}) do
    {:ok, asset} = AssetModel.get(id)
    AssetModel.delete(asset)
    nil
  end

  defp sensor_creation(%{"name" => name}, org_id, parent_id, parent_type, parent_entity) do
    case parent_entity do
      nil ->
        SensorModel.create(%{
          name: name,
          parent_id: parent_id,
          parent_type: parent_type,
          org_id: org_id
        })

      _ ->
        SensorModel.create(%{
          name: name,
          parent_id: parent_entity.id,
          parent_type: "Asset",
          org_id: org_id
        })
    end

    nil
  end

  defp sensor_updation(
         %{"id" => id, "name" => name, "parent_id" => parent_id, "parent_type" => parent_type},
         org_id
       ) do
    {:ok, sensor} = SensorModel.get(id)

    SensorModel.update(sensor, %{
      name: name,
      parent_id: parent_id,
      parent_type: parent_type
    })

    nil
  end

  defp sensor_deletion(%{"id" => id}) do
    SensorModel.delete(id)
    nil
  end
end
