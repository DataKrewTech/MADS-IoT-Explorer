defmodule AcqdatApi.EntityManagement.EntityParser do
  alias AcqdatCore.Model.EntityManagement.Sensor, as: SensorModel
  alias AcqdatCore.Model.EntityManagement.Asset, as: AssetModel
  alias AcqdatCore.Model.EntityManagement.Organisation, as: OrgModel
  alias AcqdatCore.Model.EntityManagement.Project, as: ProjectModel
  alias AcqdatCore.Schema.EntityManagement.Project
  alias AcqdatCore.Repo

  # TODO: Error handling to do
  # TODO: Needs to refactor this parser
  def update_project_hierarchy(
        project,
        %{"org_id" => org_id, "type" => type, "entities" => entities} = params
      ) do
    {org_id, _} = Integer.parse(org_id)
    validate_tree_hirerachy(parse_n_update(entities, org_id, nil, type, params), project)
  end

  defp validate_tree_hirerachy({:ok, result}, project) do
    validate_parser_result(result, project)
  end

  defp validate_tree_hirerachy({:error, message}, _project) do
    {:error, message}
  end

  defp validate_parser_result(result, project) do
    validate_res(Enum.filter(List.flatten(result_parsing(result)), &(!is_nil(&1))), project)
  end

  defp validate_res(data, project) when length(data) == 0 do
    ProjectModel.update_version(project)
    {:ok, "success"}
  end

  defp validate_res(data, _project) when length(data) != 0 do
    {:error, data}
  end

  defp result_parsing(result) do
    data = []

    case result do
      {:error, message} ->
        data ++ [message]

      _ ->
        if length(result) != 0 do
          for res <- result do
            if res != nil do
              {:ok, list} = res
              data ++ result_parsing(list)
            end
          end
        end
    end
  end

  defp parse_n_update(entities, org_id, parent_id, parent_type, parent_entity)
       when entities !== nil do
    Repo.transaction(fn ->
      try do
        for entity <- entities do
          result = entity_seggr(entity, org_id, parent_id, parent_type, parent_entity)

          case result do
            {:ok, {:delete_asset, _data}} ->
              nil

            {:ok, parent_entity} ->
              parse_n_update(
                entity["entities"],
                org_id,
                entity["id"],
                entity["type"],
                parent_entity
              )

            {:error, message} ->
              throw(message)

            _ ->
              parse_n_update(entity["entities"], org_id, entity["id"], entity["type"], nil)
          end
        end
      catch
        message ->
          {:error, message}
      end
    end)
  end

  defp parse_n_update(entities, _org_id, _parent_id, _parent_type, _parent_entity)
       when entities == nil do
    nil
  end

  defp entity_seggr(
         %{"id" => id, "type" => type, "version" => version},
         _org_id,
         _parent_id,
         _parent_type,
         _parent_entity
       )
       when type == "Project" do
    project_version = version |> Decimal.new()
    validate_project(ProjectModel.get_by_id(id), project_version)
  end

  defp entity_seggr(
         %{"type" => type, "action" => action} = entity,
         org_id,
         parent_id,
         parent_type,
         parent_entity
       )
       when type == "Asset" and action == "create" do
    asset_creation(entity, org_id, parent_id, parent_type, parent_entity)
  end

  defp entity_seggr(
         %{"type" => type, "action" => action} = entity,
         org_id,
         _parent_id,
         _parent_type,
         _parent_entity
       )
       when type == "Asset" and action == "update" do
    asset_updation(entity, org_id)
  end

  defp entity_seggr(
         %{"type" => type, "action" => action} = entity,
         _org_id,
         _parent_id,
         _parent_type,
         _parent_entity
       )
       when type == "Asset" and action == "delete" do
    asset_deletion(entity)
  end

  defp entity_seggr(
         %{"type" => type, "action" => action} = entity,
         org_id,
         parent_id,
         parent_type,
         parent_entity
       )
       when type == "Sensor" and action == "create" do
    sensor_creation(entity, org_id, parent_id, parent_type, parent_entity)
  end

  defp entity_seggr(
         %{"type" => type, "action" => action} = entity,
         org_id,
         _parent_id,
         _parent_type,
         _parent_entity
       )
       when type == "Sensor" and action == "update" do
    sensor_updation(entity, org_id)
  end

  defp entity_seggr(
         %{"type" => type, "action" => action} = entity,
         _org_id,
         _parent_id,
         _parent_type,
         _parent_entity
       )
       when type == "Sensor" and action == "delete" do
    sensor_deletion(entity)
  end

  defp entity_seggr(%{"type" => _type}, _org_id, _parent_id, _parent_type, _parent_entity) do
    nil
  end

  defp asset_creation(entity, org_id, _parent_id, parent_type, parent_entity)
       when parent_type == "Project" do
    add_asset_as_root(entity, org_id, parent_entity.id)
  end

  defp asset_creation(entity, org_id, parent_id, parent_type, parent_entity)
       when parent_type == "Asset" and is_nil(parent_entity) do
    add_asset_as_child(entity, org_id, parent_id)
  end

  defp asset_creation(entity, org_id, _parent_id, parent_type, parent_entity)
       when parent_type == "Asset" do
    add_asset_as_child(entity, org_id, parent_entity.id)
  end

  defp add_asset_as_root(%{"name" => name}, org_id, project_id) do
    validate_organisation(OrgModel.get_by_id(org_id), name, project_id)
  end

  defp validate_organisation({:ok, org}, asset_name, project_id) do
    AssetModel.add_as_root(%{
      name: asset_name,
      org_id: org.id,
      org_name: org.name,
      project_id: project_id
    })
  end

  defp validate_organisation({:error, _}, _asset_name, _project_id) do
    {:error, "Organisation not found"}
  end

  defp add_asset_as_child(%{"name" => name}, org_id, parent_id) do
    # {:ok, parent_entity} = AssetModel.get(parent_id)
    # AssetModel.add_as_child(parent_entity, name, org_id, :child)
    validate_parent_asset(AssetModel.get(parent_id), name, org_id)
  end

  defp validate_parent_asset({:ok, parent_entity}, asset_name, org_id) do
    AssetModel.add_as_child(parent_entity, asset_name, org_id, :child)
  end

  defp validate_parent_asset({:error, _}, _asset_name, _org_id) do
    {:error, "Asset not found"}
  end

  defp asset_updation(%{"id" => id, "name" => name}, _org_id) do
    validate_asset(AssetModel.get(id), %{
      name: name,
      action: "update"
    })
  end

  defp asset_deletion(%{"id" => id}) do
    validate_asset(AssetModel.get(id), %{action: "delete"})
  end

  defp sensor_creation(%{"name" => name}, org_id, parent_id, parent_type, nil) do
    validate_sensor_asset(AssetModel.get(parent_id), name, org_id, parent_id, parent_type)
  end

  defp sensor_creation(%{"name" => name}, org_id, _parent_id, _parent_type, parent_entity) do
    SensorModel.create(%{
      name: name,
      parent_id: parent_entity.id,
      parent_type: "Asset",
      org_id: org_id,
      project_id: parent_entity.project_id
    })
  end

  defp validate_sensor_asset({:ok, asset}, name, org_id, parent_id, parent_type) do
    SensorModel.create(%{
      name: name,
      parent_id: parent_id,
      parent_type: parent_type,
      org_id: org_id,
      project_id: asset.project_id
    })
  end

  defp validate_sensor_asset({:error, _message}, _name, _org_id, _parent_id, _parent_type) do
    {:error, "Asset not found"}
  end

  defp sensor_updation(
         %{"id" => id, "name" => name},
         _org_id
       ) do
    {:ok, sensor} = SensorModel.get(id)

    SensorModel.update(sensor, %{
      name: name
      # parent_id: parent_id,
      # parent_type: parent_type
    })
  end

  defp sensor_deletion(%{"id" => id}) do
    SensorModel.delete(id)
  end

  defp validate_asset({:ok, asset}, %{action: action}) when action == "delete" do
    case AssetModel.delete(asset) do
      {:ok, {:ok, _data}} ->
        {:ok, {:delete_asset, "success"}}

      {:ok, {:error, message}} ->
        {:error, message}
    end
  end

  defp validate_asset({:ok, asset}, %{action: action, name: name}) when action == "update" do
    AssetModel.update_asset(asset, %{
      name: name
    })
  end

  defp validate_asset({:error, _message}, _params) do
    {:error, "Asset not found"}
  end

  defp validate_project({:ok, %Project{version: p_version} = project}, version)
       when p_version == version do
    {:ok, project}
  end

  defp validate_project({:ok, %Project{version: p_version}}, version) when p_version != version do
    {:error, "Please update your current tree version"}
  end

  defp validate_project({:error, _}, _version) do
    {:error, "Project not found"}
  end
end
