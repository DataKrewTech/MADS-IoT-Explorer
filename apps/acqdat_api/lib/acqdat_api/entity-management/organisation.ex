defmodule AcqdatApi.EntityManagement.Organisation do
  alias AcqdatCore.Model.EntityManagement.Organisation, as: OrgModel
  alias AcqdatCore.Model.RoleManagement.User, as: UserModel
  alias AcqdatCore.Model.RoleManagement.Role
  alias Ecto.Multi
  alias AcqdatCore.ElasticSearch
  import Tirexs.HTTP
  import AcqdatApiWeb.Helpers
  alias AcqdatCore.Repo

  defdelegate get(id), to: OrgModel
  defdelegate update(org, data), to: OrgModel
  defdelegate get_all(data, preloads), to: OrgModel
  defdelegate delete(org), to: OrgModel

  def create(params) do
    params = params_extraction(params)

    case params.user_details do
      nil -> verify_organisation(OrgModel.create(params))
      _ -> create_organisation_and_user(params)
    end
  end

  defp verify_organisation({:ok, org}) do
    {:ok, org}
  end

  defp verify_organisation({:error, message}) do
    {:error, %{error: extract_changeset_error(message)}}
  end

  defp create_organisation_and_user(params) do
    verify_organisation(
      Multi.new()
      |> Multi.run(:create_organisation, fn _, _changes ->
        OrgModel.create(params)
      end)
      |> Multi.run(:create_user, fn _, %{create_organisation: organisation} ->
        role_id = Role.get_role_id("manager")

        user_details =
          params.user_details
          |> Map.put_new("org_id", organisation.id)
          |> Map.put_new("is_invited", false)
          |> Map.replace!("role_id", role_id)

        UserModel.create(user_details)
      end)
      |> run_transaction()
    )
  end

  defp run_transaction(multi_query) do
    result = Repo.transaction(multi_query)

    case result do
      {:ok,
       %{
         create_user: user,
         create_organisation: organisation
       }} ->
        user_create_es(user)
        {:ok, organisation}

      {:error, _failed_operation, failed_value, _changes_so_far} ->
        {:error, failed_value}
    end
  end

  defp params_extraction(params) do
    Map.from_struct(params)
    |> Map.drop([:_id, :__meta__])
  end

  defp user_create_es(params) do
    post("organisation/_doc/#{params.id}?routing=#{params.org_id}",
      id: params.id,
      email: params.email,
      first_name: params.first_name,
      last_name: params.last_name,
      org_id: params.org_id,
      is_invited: params.is_invited,
      role_id: params.role_id,
      join_field: %{name: "user", parent: params.org_id}
    )
  end
end
