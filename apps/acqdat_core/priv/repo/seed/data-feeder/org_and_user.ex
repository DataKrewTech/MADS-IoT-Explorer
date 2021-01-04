defmodule AcqdatCore.Seed.DataFeeder.OrgAndUser do
  alias AcqdatCore.Schema.EntityManagement.Organisation
  alias AcqdatCore.Schema.RoleManagement.User
  alias AcqdatCore.Repo
  import Tirexs.HTTP

  def seed_data!() do
    create_index()
    organisations = Repo.all(Organisation)
    Enum.each(organisations, fn org ->
      insert_organisation("organisation", org)
    end)
    users = Repo.all(User) |> Repo.preload([:org])
    Enum.each(users, fn user ->
      create("organisation", user, user.org)
    end)
  end

  defp create_index() do
    put("/organisation",%{mappings: %{properties: %{join_field: %{type: "join", relations: %{organisation: "user"}}}}})
  end

  defp insert_organisation(type, params) do
    post("#{type}/_doc/#{params.id}",
      id: params.id,
      name: params.name,
      uuid: params.uuid,
      "join_field": "organisation"
      )
  end

  defp create(type, params, org) do
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
