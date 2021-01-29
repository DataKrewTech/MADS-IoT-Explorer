defmodule AcqdatCore.Factory.ElasticSearch.User do
  alias AcqdatCore.ElasticSearch
  import AcqdatCore.Support.Factory
  import Tirexs.HTTP

  def create_index() do
    put("/organisation", %{
      mappings: %{properties: %{join_field: %{type: "join", relations: %{organisation: "user"}}}}
    })
  end

  def seed_user(user) do
    ElasticSearch.create_user("organisation", user, user.org)
    [user: user]
  end

  def delete_index() do
    delete("/organisation")
  end

  def seed_multiple_user(org, count) do
    [user1, user2, user3] = insert_list(count, :user, org: org)
    ElasticSearch.create_user("organisation", user1, user1.org)
    ElasticSearch.create_user("organisation", user2, user2.org)
    ElasticSearch.create_user("organisation", user3, user3.org)
    [user1, user2, user3]
  end
end
