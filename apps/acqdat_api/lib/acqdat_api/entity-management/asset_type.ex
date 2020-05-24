defmodule AcqdatApi.EntityManagement.AssetType do
  alias AcqdatCore.Model.EntityManagement.AssetType, as: AssetTypeModel

  defdelegate get(id), to: AssetTypeModel
  defdelegate update(asset_type, data), to: AssetTypeModel
  defdelegate delete(asset_type), to: AssetTypeModel
end
