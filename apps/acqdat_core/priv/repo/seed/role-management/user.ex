defmodule AcqdatCore.Seed.RoleManagement.User do
  alias AcqdatCore.Schema.RoleManagement.{User, Role}
  alias AcqdatCore.Schema.EntityManagement.Organisation
  alias AcqdatCore.Repo
  import Tirexs.HTTP

  def seed_user!() do
    [org] = Repo.all(Organisation)
    role = Repo.get(Role, 1)
    params = %{
      first_name: "Chandu",
      last_name: "Developer",
      email: "chandu@stack-avenue.com",
      password: "datakrew",
      password_confirmation: "datakrew",
      org_id: org.id,
      role_id: role.id,
      is_invited: false
    }
    user = User.changeset(%User{}, params)
    data = Repo.insert!(user, on_conflict: :nothing)
    create("users", data)
  end

  #put("/organisation",%{mappings: %{properties: %{join_field: %{type: "join", relations: %{organisation: "user"}}}}})
  def create(type, params) do
    post("#{type}/_doc/#{params.id}",
      id: params.id,
      email: params.email,
      first_name: params.first_name,
      last_name: params.last_name,
      org_id: params.org_id,
      is_invited: params.is_invited,
      role_id: params.role_id)
  end
end
