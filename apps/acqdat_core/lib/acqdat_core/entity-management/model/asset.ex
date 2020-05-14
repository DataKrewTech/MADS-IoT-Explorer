defmodule AcqdatCore.Model.EntityManagement.Asset do
  import AsNestedSet.Modifiable
  import Ecto.Query
  alias AcqdatCore.Model.EntityManagement.Sensor, as: SensorModel
  alias AcqdatCore.Schema.EntityManagement.Asset
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
    case Repo.get(Asset, id) |> Repo.preload([:org]) do
      nil ->
        {:error, "not found"}

      asset ->
        {:ok, asset}
    end
  end

  def update_asset(asset, params) do
    changeset = Asset.update_changeset(asset, params)
    Repo.update(changeset)
  end

  def delete(asset) do
    AsNestedSet.delete(asset) |> AsNestedSet.execute(Repo)
  end

  def add_as_root(%{name: name, org_id: org_id, org_name: org_name}) do
    # NOTE: function Ecto.Changeset.__as_nested_set_column_name__/1 is undefined or private
    try do
      taxon =
        asset_struct(%{name: name, org_id: org_id, slug: org_name <> name})
        |> create(:root)
        |> AsNestedSet.execute(Repo)

      {:ok, taxon}
    rescue
      error in Ecto.InvalidChangesetError ->
        {:error, error.changeset}
    end
  end

  def add_as_child(parent, name, org_id, position) do
    try do
      child =
        asset_struct(%{name: name, org_id: org_id, slug: parent.org.name <> parent.name <> name})

      taxon =
        child
        |> create(parent, position)
        |> AsNestedSet.execute(Repo)

      {:ok, taxon}
    rescue
      error in Ecto.InvalidChangesetError ->
        {:error, error.changeset}
    end
  end

  defp asset_struct(%{name: name, org_id: org_id, slug: slug}) do
    %Asset{
      name: name,
      org_id: org_id,
      inserted_at: DateTime.truncate(DateTime.utc_now(), :second),
      updated_at: DateTime.truncate(DateTime.utc_now(), :second),
      uuid: UUID.uuid1(:hex),
      slug: Slugger.slugify(slug),
      properties: []
    }
  end

  def asset_descendents(asset) do
    entities = asset |> AsNestedSet.descendants() |> AsNestedSet.execute(Repo)
    fetch_child_sensors(List.first(entities), entities, asset)
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
