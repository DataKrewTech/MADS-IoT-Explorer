defmodule AcqdatCore.Factory.ElasticSearch.User do
  alias AcqdatApi.ElasticSearch
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

  def seed_multiple_user() do
    [user1, user2, user3] = insert_list(3, :user)
    ElasticSearch.create_user("organisation", user1, user1.org)
    ElasticSearch.create_user("organisation", user2, user2.org)
    ElasticSearch.create_user("organisation", user3, user3.org)
  end
end
