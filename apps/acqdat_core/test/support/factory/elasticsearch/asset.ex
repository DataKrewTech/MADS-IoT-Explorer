defmodule AcqdatCore.Factory.ElasticSearch.Asset do
  alias AcqdatApi.ElasticSearch
  import AcqdatCore.Support.Factory
  import Tirexs.HTTP

  def seed_asset(asset) do
    ElasticSearch.insert_asset("assets", asset)
  end

  def delete_index() do
    delete("/assets")
  end

  def seed_multiple_assets(project, count) do
    [asset1, asset2, asset3] = insert_list(count, :asset, project: project, org: project.org)
    ElasticSearch.insert_asset("assets", asset1)
    ElasticSearch.insert_asset("assets", asset2)
    ElasticSearch.insert_asset("assets", asset3)
    [asset1, asset2, asset3]
  end
end
