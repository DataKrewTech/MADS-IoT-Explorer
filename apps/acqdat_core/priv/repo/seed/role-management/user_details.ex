defmodule AcqdatCore.Seed.RoleManagement.UserDetails do
  alias AcqdatCore.Schema.RoleManagement.User
  alias AcqdatCore.Model.RoleManagement.User, as: UserModel
  alias AcqdatCore.Model.RoleManagement.UserCredentials
  alias AcqdatCore.Repo
  import Tirexs.HTTP

  def migrate_user_details!() do
    users = Repo.all(User)
    Enum.each(users, fn user ->
      details = [user.first_name, user.last_name, user.email, user.password_hash, user.phone_number]
      user_credentials = create_user_credentials(details)
      params = %{user_credentials_id: user_credentials.id}
      UserModel.update_user(user, params)
    end)

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

  defp create_user_credentials([first_name, last_name, email, password_hash, phone_number]) do
    params = %{
      first_name: first_name,
      last_name: last_name,
      email: email,
      password_hash: password_hash,
      phone_number: phone_number
    }
    {:ok, user_cred} = UserCredentials.create(params)
    user_cred
  end
end
