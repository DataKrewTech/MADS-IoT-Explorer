defmodule AcqdatCore.Seed.RoleManagement.User do
  alias AcqdatCore.Schema.RoleManagement.{User, UserCredentials, Role}
  alias AcqdatCore.Schema.EntityManagement.Organisation
  alias AcqdatCore.Repo
  import Tirexs.HTTP

  def seed_user!() do
    [org] = Repo.all(Organisation)
    role = Repo.get(Role, 1)
    params = %{
      first_name: "Datakrew",
      last_name: "Admin",
      email: System.get_env("USER_EMAIL"),
      password: System.get_env("USER_PASSWORD"),
      password_confirmation: System.get_env("USER_PASSWORD"),
    }

    user_cred = UserCredentials.changeset(%UserCredentials{}, params)
    data = Repo.insert!(user_cred)

    params = %{
      org_id: org.id,
      role_id: role.id,
      is_invited: false,
      user_credentials_id: data.id
    }
    user = User.changeset(%User{}, params)
    data = Repo.insert!(user, on_conflict: :nothing)
    create("organisation", data, org)
  end

  def create(type, params, org) do
    post("#{type}/_doc/#{params.id}?routing=#{org.id}",
      id: params.id,
      email: params.email,
      first_name: params.first_name,
      last_name: params.last_name,
      org_id: params.org_id,
      is_invited: params.is_invited,
      role_id: params.role_id,
      "join_field": %{"name": "user", "parent": org.id}
      )
  end
end
