defmodule AcqdatCore.Model.Organisation do
  import Ecto.Query
  import AsNestedSet.Queriable, only: [dump_one: 2]
  alias AcqdatCore.Schema.Organisation
  alias AcqdatCore.Model.Asset, as: AssetModel
  alias AcqdatCore.Schema.Sensor
  alias AcqdatCore.Repo

  def get(id) when is_integer(id) do
    case Repo.get(Organisation, id) do
      nil ->
        {:error, "not found"}

      org ->
        entities = AssetModel.child_assets(org.id)

        org = Map.put_new(org, :assets, entities)
        {:ok, org}
    end
  end
end
