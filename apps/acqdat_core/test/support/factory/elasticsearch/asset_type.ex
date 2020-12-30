defmodule AcqdatCore.Factory.ElasticSearch.AssetType do
  alias AcqdatApi.ElasticSearch
  import AcqdatCore.Support.Factory
  import Tirexs.HTTP

  def seed_asset_type(asset_type) do
    ElasticSearch.insert_asset_type("asset_types", asset_type)
  end

  def delete_index() do
    delete("/asset_types")
  end

  def seed_multiple_assets_type(project, count) do
    [asset_type1, asset_type2, asset_type3] =
      insert_list(count, :asset_type, project: project, org: project.org)

    ElasticSearch.insert_asset_type("asset_types", asset_type1)
    ElasticSearch.insert_asset_type("asset_types", asset_type2)
    ElasticSearch.insert_asset_type("asset_types", asset_type3)
    [asset_type1, asset_type2, asset_type3]
  end
end
