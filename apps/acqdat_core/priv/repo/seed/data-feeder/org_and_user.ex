defmodule AcqdatCore.Seed.DataFeeder.OrgAndUser do
  alias AcqdatCore.Schema.EntityManagement.Organisation
  alias AcqdatCore.Schema.RoleManagement.User
  alias AcqdatCore.Model.RoleManagement.UserCredentials, as: UCModel
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
    post("#{type}/_doc/#{params.id}?refresh=true",
      id: params.id,
      name: params.name,
      uuid: params.uuid,
      inserted_at: DateTime.to_unix(params.inserted_at),
      "join_field": "organisation"
      )
  end

  def create(type, params, org) do
    {:ok, user_cred} = UCModel.get(params.user_credentials_id)
      post("organisation/_doc/#{params.id}?routing=#{params.org_id}",
        id: params.id,
        email: user_cred.email,
        first_name: user_cred.first_name,
        last_name: user_cred.last_name,
        org_id: params.org_id,
        is_invited: params.is_invited,
        role_id: params.role_id,
        inserted_at: DateTime.to_unix(params.inserted_at),
        join_field: %{name: "user", parent: params.org_id}
      )
  end
end
