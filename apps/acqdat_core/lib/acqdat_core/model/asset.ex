defmodule AcqdatCore.Model.Asset do
  import Ecto.Query
  import AsNestedSet.Queriable, only: [dump_one: 2]
  import AsNestedSet.Modifiable
  alias AcqdatCore.Model.Sensor, as: SensorModel
  alias AcqdatCore.Schema.Asset
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

  def get(id) when is_integer(id) do
    case Repo.get(Asset, id) do
      nil ->
        {:error, "not found"}

      asset ->
        {:ok, asset}
    end
  end

  def delete(asset) do
    AsNestedSet.delete(asset) |> AsNestedSet.execute(Repo)
  end

  def add_as_root(%{name: name, org_id: org_id}) do
    asset = %Asset{
      name: name,
      org_id: org_id,
      inserted_at: DateTime.truncate(DateTime.utc_now(), :second),
      updated_at: DateTime.truncate(DateTime.utc_now(), :second),
      uuid: UUID.uuid1(:hex),
      slug: Slugger.slugify(random_string(12)),
      properties: []
    }

    asset
    |> create(:root)
    |> AsNestedSet.execute(Repo)
  end

  def add_as_child(parent, name, org_id, position) do
    child = %Asset{
      name: name,
      org_id: org_id,
      parent_id: parent.id,
      uuid: UUID.uuid1(:hex),
      slug: Slugger.slugify(random_string(12)),
      inserted_at: DateTime.truncate(DateTime.utc_now(), :second),
      updated_at: DateTime.truncate(DateTime.utc_now(), :second),
      properties: []
    }

    try do
      taxon =
        %Asset{child | org_id: org_id}
        |> create(parent, position)
        |> AsNestedSet.execute(Repo)

      {:ok, taxon}
    rescue
      error in Ecto.InvalidChangesetError ->
        {:error, error.changeset}
    end
  end

  defp random_string(length) do
    :crypto.strong_rand_bytes(length) |> Base.url_encode64() |> binary_part(0, length)
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
end
