defmodule AcqdatApi.AssetType do
  alias AcqdatCore.Model.AssetType, as: AssetTypeModel
  import AcqdatApiWeb.Helpers

  defdelegate get(id), to: AssetTypeModel
  defdelegate update_asset(asset_type, data), to: AssetTypeModel
end
