defmodule AcqdatCore.Factory.ElasticSearch.Project do
  alias AcqdatApi.ElasticSearch
  import AcqdatCore.Support.Factory
  import Tirexs.HTTP

  def create_index() do
    put("/org", %{
      mappings: %{properties: %{join_field: %{type: "join", relations: %{org: "project"}}}}
    })
  end

  def seed_project(project) do
    ElasticSearch.create_project("org", project, project.org)
  end

  def delete_index() do
    delete("/org")
  end

  def seed_multiple_project(org, count) do
    [project1, project2, project3] = insert_list(count, :project, org: org)
    ElasticSearch.create_project("org", project1, org)
    ElasticSearch.create_project("org", project2, org)
    ElasticSearch.create_project("org", project3, org)
    [project1, project2, project3]
  end
end
