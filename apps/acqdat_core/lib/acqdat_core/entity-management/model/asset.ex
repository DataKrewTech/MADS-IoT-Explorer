defmodule AcqdatCore.Model.EntityManagement.Asset do
  import AsNestedSet.Modifiable
  import Ecto.Query
  alias AcqdatCore.Model.EntityManagement.Sensor, as: SensorModel
  alias AcqdatCore.Model.IotManager.Gateway, as: GatewayModel
  alias AcqdatCore.Schema.EntityManagement.Asset
  alias AcqdatCore.ElasticSearch
  alias Ecto.Multi
  alias AcqdatCore.Repo
  alias AcqdatCore.Model.Helper, as: ModelHelper

  def get(id) when is_integer(id) do
    case Repo.get(Asset, id) |> Repo.preload([:org, :project, :asset_type]) do
      nil ->
        {:error, "not found"}

      asset ->
        {:ok, asset}
    end
  end

  def get_for_view(asset_ids) do
    query =
      from(asset in Asset,
        where: asset.id in ^asset_ids,
        preload: [:org, :project, :asset_type]
      )

    Repo.all(query)
  end

  def get_all_by_asset_type(entity_ids) do
    Asset
    |> where([asset], asset.asset_type_id in ^entity_ids)
    |> order_by(:id)
    |> Repo.all()
  end

  def get_all_by_ids(entity_ids) do
    Asset
    |> where([asset], asset.id in ^entity_ids)
    |> Repo.all()
  end

  def fetch_child_descendants(asset) do
    AsNestedSet.descendants(asset) |> AsNestedSet.execute(Repo)
  end

  def child_assets(project_id) do
    Asset |> dump_assets(%{project_id: project_id}) |> AsNestedSet.execute(Repo)
  end

  def child_assets_including_gateway(project_id) do
    Asset |> dump_assets_for_gateway(%{project_id: project_id}) |> AsNestedSet.execute(Repo)
  end

  @doc """
  Updates an Asset with the provided params.
  **Updating asset position**
  Updating the asset position(root or under another asset) is done by using the
  `parent_id` key. If the `parent_id` is set to `nil` the asset(with it's
  descendants) will be  moved to the root. In case the asset is to be moved
  under another asset then the target asset `id` should be provided under the
  `parent_id` key.
  All the detail and position updates are run under a transaction using
  `Ecto.Multi`. In case if there is any error while updating all the changes
  are reverted.
  """
  @spec update_asset(Asset.t(), map) ::
          {:ok, Asset.t()}
          | {:error, Ecto.Changeset.t()}
  def update_asset(asset, %{parent_id: nil} = params) do
    params = Map.drop(params, [:parent_id])

    Multi.new()
    |> Multi.run(:update_position, fn _, _changes ->
      result =
        asset
        |> AsNestedSet.move(:root)
        |> AsNestedSet.execute(Repo)

      {:ok, result}
    end)
    |> Multi.run(:update_details, fn _, %{update_position: asset} ->
      update_asset(asset, params)
    end)
    |> run_under_transaction(:update_details)
  end

  def update_asset(asset, %{parent_id: parent_id} = params) when not is_nil(parent_id) do
    {:ok, parent_asset} = get(parent_id)
    params = Map.drop(params, [:parent_id])

    Multi.new()
    |> Multi.run(:update_position, fn _, _changes ->
      result =
        asset
        |> AsNestedSet.move(parent_asset, :child)
        |> AsNestedSet.execute(Repo)

      {:ok, result}
    end)
    |> Multi.run(:update_details, fn _, %{update_position: asset} ->
      update_asset(asset, params)
    end)
    |> run_under_transaction(:update_details)
  end

  def update_asset(asset, params) when params == %{}, do: {:ok, asset}

  def update_asset(asset, params) do
    changeset = Asset.update_changeset(asset, params)

    case Repo.update(changeset) do
      {:ok, asset} ->
        Task.start_link(fn ->
          ElasticSearch.update_asset("assets", asset)
        end)

        {:ok, asset}

      {:error, error} ->
        {:error, error}
    end
  end

  def fetch_root(org_id, parent_id) do
    query =
      from(asset in Asset,
        where: asset.org_id == ^org_id and asset.id == ^parent_id
      )

    Repo.one!(query) |> Repo.preload([:org, :project, :creator, :asset_type])
  end

  def delete(asset) do
    Repo.transaction(fn ->
      validate_and_delete_asset(asset)
    end)
  end

  def add_as_root(%{
        name: name,
        org_id: org_id,
        org_name: org_name,
        project_id: project_id,
        creator_id: creator_id,
        asset_type_id: asset_type_id,
        metadata: metadata,
        mapped_parameters: mapped_parameters,
        owner_id: owner_id,
        properties: properties
      }) do
    # NOTE: function Ecto.Changeset.__as_nested_set_column_name__/1 is undefined or private
    try do
      taxon =
        asset_struct(%{
          name: name,
          org_id: org_id,
          slug: org_name <> name,
          project_id: project_id,
          creator_id: creator_id,
          asset_type_id: asset_type_id,
          metadata: metadata,
          mapped_parameters: mapped_parameters,
          owner_id: owner_id,
          properties: properties
        })
        |> create(:root)
        |> AsNestedSet.execute(Repo)

      Task.start_link(fn ->
        ElasticSearch.insert_asset("assets", taxon)
      end)

      {:ok, taxon}
    rescue
      error in Ecto.InvalidChangesetError ->
        {:error, error.changeset}
    end
  end

  @doc """
  "add_as_child" function is used to create child assets from a given asset.
  Here parent is the root asset and name and org_id is used
  for the classification  and position is the position which can be [:child, :left, :right].
  """

  def add_as_child(%Asset{} = parent, %Asset{} = child, position) do
    try do
      taxon =
        %Asset{child | org_id: parent.org.id}
        |> Repo.preload(:org)
        |> create(parent, position)
        |> AsNestedSet.execute(Repo)

      Task.start_link(fn ->
        ElasticSearch.insert_asset("assets", taxon)
      end)

      {:ok, taxon}
    rescue
      error in Ecto.InvalidChangesetError ->
        {:error, error.changeset}
    end
  end

  def asset_descendants(asset) do
    asset_descen_tree =
      Asset |> dump_assets(%{project_id: asset.project_id}, asset.id) |> AsNestedSet.execute(Repo)

    sensor_des = fetch_asset_descendants_map(nil, asset, asset)
    Map.put_new(sensor_des, :assets, asset_descen_tree)
  end

  def fetch_root_assets(project_id) do
    query =
      from(asset in Asset,
        where: asset.project_id == ^project_id and is_nil(asset.parent_id) == true
      )

    Repo.all(query)
  end

  def fetch_mapped_parameters(asset) do
    Enum.reduce(asset.sensors, [], fn sensor, acc ->
      res_params = gen_asset_mapped_params(sensor)
      acc ++ res_params
    end)
  end

  ############################# private functions ###########################

  defp gen_asset_mapped_params(%{sensor_type: sensor_type} = sensor) do
    Enum.map(sensor_type.parameters, fn parameter ->
      %{
        name: parameter.name,
        parameter_uuid: parameter.uuid,
        sensor_uuid: sensor.uuid,
        sensor_type_uuid: sensor.sensor_type.uuid
      }
    end)
  end

  defp dump_assets(module, scope, parent_id \\ nil) do
    fn repo ->
      children = fetch_child_assets(repo, module, scope, parent_id)

      Enum.reduce(children, [], fn asset, acc ->
        res_asset = dump_assets(module, scope, asset.id).(repo)
        sensor_entities = fetch_asset_descendants_map(nil, res_asset, asset)

        res_asset = fetch_asset_descendants_map(List.first(res_asset), res_asset, sensor_entities)
        acc ++ [res_asset]
      end)
    end
  end

  defp dump_assets_for_gateway(module, scope, parent_id \\ nil) do
    fn repo ->
      children = fetch_child_assets(repo, module, scope, parent_id)

      Enum.reduce(children, [], fn asset, acc ->
        res_asset = dump_assets(module, scope, asset.id).(repo)
        sensor_entities = fetch_asset_descendants_map_for_gateway(nil, res_asset, asset)

        res_asset =
          fetch_asset_descendants_map_for_gateway(
            List.first(res_asset),
            res_asset,
            sensor_entities
          )

        acc ++ [res_asset]
      end)
    end
  end

  # NOTE: Taken reference from as_nested_set queriable module dump function:
  # https://github.com/secretworry/as_nested_set/blob/1883d61796c676fdb610c6be19fd565f501635de/lib/as_nested_set/queriable.ex#L117
  defp fetch_child_assets(repo, module, scope, parent_id) do
    parent_id_column = :parent_id
    left_column = :lft

    if parent_id do
      from(q in module,
        preload: [:asset_type],
        where: field(q, ^parent_id_column) == ^parent_id,
        order_by: ^[left_column]
      )
    else
      from(q in module,
        preload: [:asset_type],
        where: is_nil(field(q, ^parent_id_column)),
        order_by: ^[left_column]
      )
    end
    |> AsNestedSet.Scoped.scoped_query(scope)
    |> repo.all
  end

  # fetch_asset_descendants_map" function will return all the sensors of the leaf
  # asset.
  defp fetch_asset_descendants_map(nil, _entities, asset) do
    sensors = SensorModel.child_sensors(asset)
    Map.put_new(asset, :sensors, sensors)
  end

  # fetch_asset_descendants_map" function will return all the descendants(assets/sensors)
  # of the respective asset.
  defp fetch_asset_descendants_map(_data, entities, asset) do
    entities_with_sensors =
      Enum.reduce(entities, [], fn asset, acc_sensor ->
        entities = SensorModel.child_sensors(asset)
        asset = Map.put_new(asset, :sensors, entities)
        acc_sensor ++ [asset]
      end)

    Map.put_new(asset, :assets, entities_with_sensors)
  end

  # fetch_asset_descendants_map" function will return all the sensors + gateways of the leaf
  # asset.
  defp fetch_asset_descendants_map_for_gateway(nil, _entities, asset) do
    sensors = SensorModel.child_sensors(asset)
    gateways = GatewayModel.child_gateways(asset)
    asset = Map.put_new(asset, :sensors, sensors)
    Map.put_new(asset, :gateways, gateways)
  end

  # fetch_asset_descendants_map" function will return all the descendants(assets/sensors/gateway)
  # of the respective asset.
  defp fetch_asset_descendants_map_for_gateway(_data, entities, asset) do
    entities_with_sensors =
      Enum.reduce(entities, [], fn asset, acc_sensor ->
        entities = SensorModel.child_sensors(asset)
        gateways = GatewayModel.child_gateways(asset)
        asset = Map.put_new(asset, :sensors, entities)
        asset = Map.put_new(asset, :gateways, gateways)
        acc_sensor ++ [asset]
      end)

    Map.put_new(asset, :assets, entities_with_sensors)
  end

  defp validate_and_delete_asset(asset) do
    case fetch_all_descendant_sensors(asset) do
      [] ->
        AsNestedSet.delete(asset) |> AsNestedSet.execute(Repo)

      _ ->
        {:error,
         "Asset #{asset.name} tree contains sensors. Please delete associated sensors before deleting asset."}
    end
  end

  defp fetch_self_n_child_descendants(asset) do
    AsNestedSet.self_and_descendants(asset)
    |> AsNestedSet.execute(Repo)
  end

  defp fetch_all_descendant_sensors(asset) do
    Enum.map(fetch_self_n_child_descendants(asset), fn asset -> asset.id end)
    |> SensorModel.child_sensors()
  end

  defp asset_struct(%{
         name: name,
         org_id: org_id,
         slug: slug,
         project_id: project_id,
         asset_type_id: asset_type_id,
         creator_id: creator_id,
         owner_id: owner_id,
         properties: properties,
         metadata: metadata
       }) do
    %Asset{
      name: name,
      org_id: org_id,
      project_id: project_id,
      inserted_at: DateTime.truncate(DateTime.utc_now(), :second),
      updated_at: DateTime.truncate(DateTime.utc_now(), :second),
      uuid: UUID.uuid1(:hex),
      slug: Slugger.slugify(slug),
      asset_type_id: asset_type_id,
      creator_id: creator_id,
      owner_id: owner_id,
      properties: properties,
      metadata: metadata
    }
    |> Repo.preload([:org, :project])
  end

  defp run_under_transaction(multi, result_key) do
    multi
    |> Repo.transaction()
    |> case do
      {:ok, result} ->
        {:ok, result[result_key]}

      {:error, _failed_operation, failed_value, _changes_so_far} ->
        {:error, failed_value}
    end
  end

  def get_all(%{
        page_size: page_size,
        page_number: page_number,
        project_id: project_id,
        org_id: org_id
      }) do
    Asset
    |> where([asset], asset.project_id == ^project_id)
    |> where([asset], asset.org_id == ^org_id)
    |> order_by(:id)
    |> Repo.paginate(page: page_number, page_size: page_size)
  end

  def get_all(
        %{page_size: page_size, page_number: page_number, project_id: project_id, org_id: org_id},
        preloads
      ) do
    paginated_asset_data =
      Asset
      |> where([asset], asset.project_id == ^project_id)
      |> where([asset], asset.org_id == ^org_id)
      |> order_by(:id)
      |> Repo.paginate(page: page_number, page_size: page_size)

    asset_data_with_preloads = paginated_asset_data.entries |> Repo.preload(preloads)

    ModelHelper.paginated_response(asset_data_with_preloads, paginated_asset_data)
  end

  def fetch_asset_metadata(asset_type_id, metadata_names) do
    from(
      asset in Asset,
      join: c in fragment("unnest(?)", asset.metadata),
      where:
        asset.asset_type_id == ^asset_type_id and fragment("?->>'name'", c) in ^metadata_names,
      select: %{
        id: asset.id,
        name: asset.name,
        value: fragment("?->>'value'", c),
        metadata_name: fragment("?->>'name'", c)
      }
    )
    |> Repo.all()
  end
end
