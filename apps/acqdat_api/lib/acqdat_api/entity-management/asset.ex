defmodule AcqdatApi.EntityManagement.Asset do
  alias AcqdatCore.Model.EntityManagement.Asset, as: AssetModel

  defdelegate asset_descendents(id), to: AssetModel
  defdelegate get(id), to: AssetModel
  defdelegate update_asset(asset, data), to: AssetModel
end
