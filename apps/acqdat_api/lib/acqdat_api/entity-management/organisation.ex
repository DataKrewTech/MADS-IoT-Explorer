defmodule AcqdatApi.EntityManagement.Organisation do
  alias AcqdatCore.Model.EntityManagement.Organisation, as: OrgModel
  alias AcqdatCore.Model.RoleManagement.User, as: UserModel
  alias AcqdatCore.Model.RoleManagement.Role
  alias AcqdatCore.Model.RoleManagement.UserCredentials
  alias Ecto.Multi
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
      |> Multi.run(:create_organisation, fn _, _ ->
        OrgModel.create(params)
      end)
      |> Multi.run(:create_user, fn _, %{create_organisation: organisation} ->
        role_id = Role.get_role_id("orgadmin")

        user_details =
          params.user_details
          |> Map.put_new("org_id", organisation.id)
          |> Map.put_new("is_invited", false)
          |> Map.replace!("role_id", role_id)

        case UserCredentials.create(user_details) do
          {:ok, user_cred} ->
            user_details =
              user_details
              |> Map.put_new("user_credentials_id", user_cred.id)

            UserModel.create(user_details)

          {:error, _} ->
            {:ok, user_cred} = UserCredentials.get(user_details["email"])

            user_details =
              user_details
              |> Map.put_new("user_credentials_id", user_cred.id)

            UserModel.create(user_details)
        end
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

      {:error, _, failed_value, _} ->
        {:error, failed_value}
    end
  end

  defp params_extraction(params) do
    Map.from_struct(params)
    |> Map.drop([:_id, :__meta__])
  end

  defp user_create_es(params) do
    {:ok, user_cred} = UserCredentials.get(params.user_credentials_id)

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
