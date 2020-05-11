defmodule AcqdatApi.Asset do
  alias AcqdatCore.Model.Asset, as: AssetModel
  import AcqdatApiWeb.Helpers

  defdelegate asset_descendents(id), to: AssetModel
  defdelegate get(id), to: AssetModel
  defdelegate update_asset(asset, data), to: AssetModel
end
