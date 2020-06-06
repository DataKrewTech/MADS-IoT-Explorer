defmodule AcqdatApi.EntityManagement.EntityParser do
  alias AcqdatCore.Model.EntityManagement.Sensor, as: SensorModel
  alias AcqdatCore.Model.EntityManagement.Asset, as: AssetModel
  alias AcqdatCore.Model.EntityManagement.Organisation, as: OrgModel
  alias AcqdatCore.Model.EntityManagement.Project, as: ProjectModel
  alias AcqdatCore.Schema.EntityManagement.{Project, Asset}
  alias AcqdatCore.Repo

  def update_project_hierarchy(
        current_user,
        project,
        %{"org_id" => org_id, "type" => type, "entities" => entities} = params
      ) do
    {org_id, _} = Integer.parse(org_id)

    validate_tree_hirerachy(
      parse_n_update(entities, org_id, nil, type, params, current_user),
      project
    )
  end

  ############################# private functions ###########################

  defp validate_tree_hirerachy({:ok, result}, project) do
    validate_parser_result(result, project)
  end

  defp validate_tree_hirerachy({:error, :rollback}, _project) do
    {:error, "Something went wrong. Please verify your hirerachy tree."}
  end

  defp validate_tree_hirerachy({:error, message}, _project) do
    {:error, message}
  end

  defp validate_parser_result(result, project) do
    result
    |> result_parsing()
    |> List.flatten()
    |> Enum.filter(&(!is_nil(&1)))
    |> validate_res(project)
  end

  defp validate_res(data, project) when length(data) == 0 do
    ProjectModel.update_version(project)
    {:ok, "success"}
  end

  defp validate_res(data, _project) when length(data) != 0 do
    {:error, data}
  end

  defp result_parsing(result) do
    validate_result(result, [])
  end

  defp validate_result({:error, message}, data) do
    data ++ [message]
  end

  defp validate_result(result, data) when length(result) != 0 do
    for res <- result do
      if res != nil do
        {:ok, list} = res
        data ++ result_parsing(list)
      end
    end
  end

  defp validate_result(result, data) when length(result) == 0 do
    nil
  end

  defp parse_n_update(entities, org_id, parent_id, parent_type, parent_entity, current_user)
       when entities !== nil do
    Repo.transaction(fn ->
      try do
        for entity <- entities do
          result =
            entity_seggr(entity, org_id, parent_id, parent_type, parent_entity, current_user)

          case result do
            {:ok, {:delete_asset, _data}} ->
              nil

            {:ok, parent_entity} ->
              parse_n_update(
                entity["entities"],
                org_id,
                entity["id"],
                entity["type"],
                parent_entity,
                current_user
              )

            {:error, message} ->
              throw(message)

            _ ->
              parse_n_update(
                entity["entities"],
                org_id,
                entity["id"],
                entity["type"],
                nil,
                current_user
              )
          end
        end
      catch
        message ->
          {:error, message}
      end
    end)
  end

  defp parse_n_update(entities, _org_id, _parent_id, _parent_type, _parent_entity, _current_user)
       when entities == nil do
    nil
  end

  defp entity_seggr(
         %{"id" => id, "type" => type, "version" => version},
         _org_id,
         _parent_id,
         _parent_type,
         _parent_entity,
         _current_user
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
         parent_entity,
         current_user
       )
       when type == "Asset" and action == "create" do
    asset_creation(entity, org_id, parent_id, parent_type, parent_entity, current_user)
  end

  defp entity_seggr(
         %{"type" => type, "action" => action} = entity,
         org_id,
         _parent_id,
         _parent_type,
         _parent_entity,
         _current_user
       )
       when type == "Asset" and action == "update" do
    asset_updation(entity, org_id)
  end

  defp entity_seggr(
         %{"type" => type, "action" => action} = entity,
         _org_id,
         _parent_id,
         _parent_type,
         _parent_entity,
         _current_user
       )
       when type == "Asset" and action == "delete" do
    asset_deletion(entity)
  end

  defp entity_seggr(
         %{"type" => type, "action" => action} = entity,
         org_id,
         parent_id,
         parent_type,
         parent_entity,
         __current_user
       )
       when type == "Sensor" and action == "create" do
    sensor_creation(entity, org_id, parent_id, parent_type, parent_entity)
  end

  defp entity_seggr(
         %{"type" => type, "action" => action} = entity,
         org_id,
         _parent_id,
         _parent_type,
         _parent_entity,
         _current_user
       )
       when type == "Sensor" and action == "update" do
    sensor_updation(entity, org_id)
  end

  defp entity_seggr(
         %{"type" => type, "action" => action} = entity,
         _org_id,
         _parent_id,
         _parent_type,
         _parent_entity,
         _current_user
       )
       when type == "Sensor" and action == "delete" do
    sensor_deletion(entity)
  end

  defp entity_seggr(
         %{"type" => _type},
         _org_id,
         _parent_id,
         _parent_type,
         _parent_entity,
         _current_user
       ) do
    nil
  end

  defp asset_creation(entity, org_id, _parent_id, parent_type, parent_entity, current_user)
       when parent_type == "Project" do
    add_asset_as_root(entity, org_id, parent_entity.id, current_user.id)
  end

  defp asset_creation(entity, org_id, parent_id, parent_type, parent_entity, current_user)
       when parent_type == "Asset" and is_nil(parent_entity) do
    add_asset_as_child(entity, org_id, parent_id, current_user.id)
  end

  defp asset_creation(entity, org_id, _parent_id, parent_type, parent_entity, current_user)
       when parent_type == "Asset" do
    add_asset_as_child(entity, org_id, parent_entity.id, current_user.id)
  end

  defp add_asset_as_root(entity, org_id, project_id, current_user_id) do
    validate_organisation(OrgModel.get_by_id(org_id), entity, project_id, current_user_id)
  end

  defp validate_organisation({:ok, org}, entity, project_id, current_user_id) do
    asset =
      entity
      |> prepare_asset_params(org.id, project_id, current_user_id)
      |> Map.put(:org_name, org.name)

    AssetModel.add_as_root(asset)
  end

  defp validate_organisation({:error, _}, _asset_name, _project_id, _current_user_id) do
    {:error, "Organisation not found"}
  end

  defp add_asset_as_child(entity, org_id, parent_id, current_user_id) do
    validate_parent_asset(AssetModel.get(parent_id), entity, org_id, current_user_id)
  end

  defp validate_parent_asset({:ok, parent_entity}, entity, org_id, current_user_id) do
    child = prepare_asset_params(entity, org_id, parent_entity.project_id, current_user_id)
    AssetModel.add_as_child(parent_entity, child, :child)
  end

  defp validate_parent_asset({:error, _}, _asset_name, _org_id) do
    {:error, "Asset not found"}
  end

  defp prepare_asset_params(params, org_id, project_id, current_user_id) do
    %Asset{
      creator_id: current_user_id,
      description: params["description"],
      image_url: params["image_url"],
      mapped_parameters: [],
      metadata: parse_metadata(params["metadata"] || []),
      name: params["name"],
      org_id: org_id,
      owner_id: params["owner_id"],
      project_id: project_id,
      asset_type_id: params["asset_type_id"],
      properties: params["properties"]
    }
  end

  defp asset_updation(%{"id" => id} = entity, _org_id) do
    validate_asset(AssetModel.get(id), %{
      entity: entity,
      action: "update"
    })
  end

  defp asset_deletion(%{"id" => id}) do
    validate_asset(AssetModel.get(id), %{action: "delete"})
  end

  defp sensor_creation(entity, org_id, parent_id, parent_type, nil) when parent_type == "Asset" do
    validate_sensor_asset(AssetModel.get(parent_id), entity, org_id, parent_id, parent_type)
  end

  defp sensor_creation(entity, org_id, _parent_id, parent_type, parent_entity)
       when parent_type == "Project" do
    SensorModel.create(%{
      name: entity["name"],
      sensor_type_id: entity["sensor_type_id"],
      parent_id: parent_entity.id,
      parent_type: parent_type,
      org_id: org_id,
      project_id: parent_entity.id,
      metadata: parse_metadata(entity["metadata"] || [])
    })
  end

  defp sensor_creation(entity, org_id, _parent_id, parent_type, parent_entity)
       when parent_type == "Asset" do
    SensorModel.create(%{
      name: entity["name"],
      sensor_type_id: entity["sensor_type_id"],
      parent_id: parent_entity.id,
      parent_type: parent_type,
      org_id: org_id,
      project_id: parent_entity.project_id,
      metadata: parse_metadata(entity["metadata"] || [])
    })
  end

  defp validate_sensor_asset({:ok, asset}, entity, org_id, parent_id, parent_type) do
    SensorModel.create(%{
      name: entity["name"],
      sensor_type_id: entity["sensor_type_id"],
      parent_id: parent_id,
      parent_type: "Asset",
      org_id: org_id,
      project_id: asset.project_id,
      metadata: parse_metadata(entity["metadata"] || [])
    })
  end

  defp parse_metadata(metadata) do
    Enum.reduce(metadata || [], [], fn x, acc ->
      x = x |> Map.new(fn {k, v} -> {String.to_atom(k), v} end)
      [x | acc]
    end)
  end

  defp validate_sensor_asset({:error, _message}, _name, _org_id, _parent_id, _parent_type) do
    {:error, "Asset not found"}
  end

  defp sensor_updation(
         %{"id" => id} = entity,
         _org_id
       ) do
    {:ok, sensor} = SensorModel.get(id)

    SensorModel.update(sensor, entity)
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

      {:ok, _} ->
        {:ok, {:delete_asset, "success"}}
    end
  end

  defp validate_asset({:ok, asset}, %{action: action, entity: entity}) when action == "update" do
    AssetModel.update_asset(asset, entity)
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
