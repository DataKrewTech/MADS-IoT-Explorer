defmodule AcqdatCore.Factory.ElasticSearch.User do
  alias AcqdatApi.ElasticSearch
  import AcqdatCore.Support.Factory
  alias AcqdatCore.Factory.ElasticSearch.User
  import Tirexs.HTTP

  def create_index(type, params) do
    put("/organisation", %{
      mappings: %{properties: %{join_field: %{type: "join", relations: %{organisation: "user"}}}}
    })

    post("#{type}/_doc/#{params.id}",
      id: params.id,
      name: params.name,
      uuid: params.uuid,
      join_field: "organisation"
    )
  end

  def seed_user(user) do
    ElasticSearch.create_user("organisation", user, user.org)
    [user: user]
  end

  def delete_index() do
    delete("/organisation")
  end

  def seed_multiple_user(org, count) do
    User.create_index("organisation", org)
    :timer.sleep(2500)
    [user1, user2, user3] = insert_list(count, :user, org: org)
    ElasticSearch.create_user("organisation", user1, user1.org)
    :timer.sleep(1000)
    ElasticSearch.create_user("organisation", user2, user2.org)
    :timer.sleep(1000)
    ElasticSearch.create_user("organisation", user3, user3.org)
    :timer.sleep(1000)
    [user1, user2, user3]
  end
end
