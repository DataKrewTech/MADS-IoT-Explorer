defmodule AcqdatCore.Model.Asset do
  import Ecto.Query
  alias AcqdatCore.Model.Sensor, as: SensorModel
  alias AcqdatCore.Schema.Asset
  alias AcqdatCore.Model.Helper, as: ModelHelper
  alias AcqdatCore.Repo

  def child_assets(project_id) do
    project_assets = fetch_root_assets(project_id)

    project_assets =
      Enum.reduce(project_assets, [], fn asset, acc ->
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

  defp fetch_root_assets(project_id) do
    query =
      from(asset in Asset,
        where: asset.project_id == ^project_id and is_nil(asset.parent_id) == true
      )

    Repo.all(query)
  end

  def get_all(%{page_size: page_size, page_number: page_number}) do
    Asset |> order_by(:id) |> Repo.paginate(page: page_number, page_size: page_size)
  end

  def get_all(%{page_size: page_size, page_number: page_number}, preloads) do
    paginated_asset_data =
      Asset |> order_by(:id) |> Repo.paginate(page: page_number, page_size: page_size)

    asset_data_with_preloads = paginated_asset_data.entries |> Repo.preload(preloads)

    ModelHelper.paginated_response(asset_data_with_preloads, paginated_asset_data)
  end
end
