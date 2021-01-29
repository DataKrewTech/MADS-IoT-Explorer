defmodule AcqdatCore.Factory.ElasticSearch.Gateway do
  alias AcqdatCore.ElasticSearch
  import AcqdatCore.Support.Factory
  import Tirexs.HTTP

  def create_index() do
    put("/pro", %{
      mappings: %{properties: %{join_field: %{type: "join", relations: %{pro: ["gateway"]}}}}
    })
  end

  def seed_gateway(gateway) do
    ElasticSearch.insert_gateway("pro", gateway)
  end

  def delete_index() do
    delete("/pro")
  end

  def seed_multiple_gateway(project, count) do
    [gateway1, gateway2, gateway3] =
      insert_list(count, :gateway, project: project, org: project.org)

    ElasticSearch.insert_gateway("pro", gateway1)
    ElasticSearch.insert_gateway("pro", gateway2)
    ElasticSearch.insert_gateway("pro", gateway3)
    [gateway1, gateway2, gateway3]
  end
end
