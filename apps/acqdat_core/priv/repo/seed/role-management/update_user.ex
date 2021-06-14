defmodule AcqdatCore.Seed.RoleManagement.UpdateUser do
  alias AcqdatCore.Schema.EntityManagement.Organisation
  alias AcqdatCore.Schema.RoleManagement.User
  alias AcqdatCore.Repo
  import Tirexs.HTTP


  def seed_data!() do
    users = Repo.all(User) |> Repo.preload([:org])
    Enum.each(users, fn user ->
      create("organisation", user, user.org)
    end)
  end

  defp create(type, params, org) do
    post("#{type}/_doc/#{params.id}?routing=#{org.id}?refresh=true",
      id: params.id,
      user_credentials_id: params.user_credentials_id,
      org_id: params.org_id,
      is_invited: params.is_invited,
      role_id: params.role_id,
      inserted_at: DateTime.to_unix(params.inserted_at),
      "join_field": %{"name": "user", "parent": org.id}
      )
  end
end
