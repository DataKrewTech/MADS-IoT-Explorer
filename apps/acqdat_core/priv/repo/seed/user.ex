defmodule AcqdatCore.Seed.User do
  alias AcqdatCore.Schema.User
  alias AcqdatApi.ElasticSearch
  alias AcqdatCore.Repo
  import Tirexs.HTTP
  import Tirexs.Search

  def seed_user!() do
    params = %{
      first_name: "Chandu",
      last_name: "Developer",
      email: "chandu@stack-avenue.com",
      password: "datakrew",
      password_confirmation: "datakrew",
    }
    user = User.changeset(%User{}, params)
    data = Repo.insert!(user, on_conflict: :nothing)
    create("users", data)
  end

  def create(type, params) do
    post("#{type}/_doc/#{params.id}",
      id: params.id,
      email: params.email,
      first_name: params.first_name,
      last_name: params.last_name)
  end
end
