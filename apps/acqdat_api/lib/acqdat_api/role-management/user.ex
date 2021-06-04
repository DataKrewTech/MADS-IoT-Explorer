defmodule AcqdatApi.RoleManagement.User do
  alias AcqdatCore.Model.RoleManagement.User, as: UserModel
  alias AcqdatCore.Model.RoleManagement.Invitation, as: InvitationModel
  alias AcqdatCore.Schema.RoleManagement.Invitation
  alias AcqdatCore.Model.RoleManagement.Policy
  alias AcqdatCore.Schema.RoleManagement.GroupUser
  alias AcqdatCore.Schema.RoleManagement.UserPolicy
  alias AcqdatCore.Model.RoleManagement.UserGroup
  alias AcqdatCore.Repo
  alias Ecto.Multi
  import AcqdatApiWeb.Helpers
  import Tirexs.HTTP
  import AcqdatApiWeb.ResMessages

  # NOTE: Currently, setting the token expiration time to be of 2 days(172800 secs)
  @token_expiration_max_age 172_800

  defdelegate update_user(user, params), to: UserModel
  defdelegate get_all(data, preloads), to: UserModel
  defdelegate get(user_id), to: UserModel

  defdelegate get_organisation(user_id), to: UserModel
  defdelegate delete(user), to: UserModel

  def set_asset(user, %{assets: assets}) do
    verify_user_assets(UserModel.set_asset(user, assets))
  end

  def set_apps(user, %{apps: apps}) do
    verify_user_apps(UserModel.set_apps(user, apps))
  end

  defp verify_user_assets({:ok, user}) do
    {:ok,
     %{
       assets: user.assets,
       email: user.email,
       id: user.id
     }}
  end

  defp verify_user_assets({:error, user}) do
    {:error, %{error: extract_changeset_error(user)}}
  end

  defp verify_user_apps({:ok, user}) do
    {:ok,
     %{
       apps: user.apps,
       email: user.email,
       id: user.id
     }}
  end

  defp verify_user_apps({:error, user}) do
    {:error, %{error: extract_changeset_error(user)}}
  end

  def create(attrs) do
    %{
      token: token,
      password: password,
      password_confirmation: password_confirmation,
      first_name: first_name,
      phone_number: phone_number,
      last_name: last_name
    } = attrs

    user_details =
      %{}
      |> Map.put(:password, password)
      |> Map.put(:password_confirmation, password_confirmation)
      |> Map.put(:first_name, first_name)
      |> Map.put(:last_name, last_name)
      |> Map.put(:phone_number, phone_number)

    fetch_existing_invitation(token, user_details)
  end

  defp fetch_existing_invitation(token, user_details) do
    fetch_invitation(InvitationModel.get_by_token(token), user_details)
  end

  defp fetch_invitation(nil, _user_details) do
    {:error, %{error: resp_msg(:invitation_is_not_valid)}}
  end

  defp fetch_invitation(
         %Invitation{
           token: token,
           salt: salt
         } = invitation,
         user_details
       ) do
    # NOTE: For token expiration and verification, referred this: https://hexdocs.pm/phoenix/Phoenix.Token.html#verify/4-examples
    validate_invitation(
      Phoenix.Token.verify(AcqdatApiWeb.Endpoint, salt, token, max_age: @token_expiration_max_age),
      invitation,
      user_details
    )
  end

  defp validate_invitation({:error, :expired}, invitation, _user_details) do
    mark_invitation_token_as_invalid(
      InvitationModel.update_invitation(invitation, %{token_valid: false})
    )
  end

  defp validate_invitation({:error, :invalid}, _invitation, _user_details) do
    {:error, %{error: resp_msg(:invalid_invitation_token)}}
  end

  defp validate_invitation(
         {:ok, _data},
         %Invitation{
           asset_ids: asset_ids,
           app_ids: app_ids,
           email: email,
           org_id: org_id,
           role_id: role_id,
           group_ids: group_ids,
           policies: policies
         } = invitation,
         user_details
       ) do
    user_details =
      user_details
      |> Map.put(:asset_ids, asset_ids)
      |> Map.put(:app_ids, app_ids)
      |> Map.put(:email, email)
      |> Map.put(:org_id, org_id)
      |> Map.put(:role_id, role_id)
      |> Map.put(:is_invited, true)
      |> Map.put(:group_ids, group_ids)
      |> Map.put(:policies, policies)

    # case to check if the invited user exist in our database and is being deleted previously
    case UserModel.get(user_details.email) do
      nil -> non_existing_user(user_details, invitation)
      user -> existing_user(user.is_deleted, user, user_details, invitation)
    end
  end

  defp existing_user(true, user, user_details, invitation) do
    user_details = Map.put(user_details, :is_deleted, false)

    verify_user(
      Multi.new()
      |> Multi.run(:update_user, fn _, _changes ->
        UserModel.update_user(user, user_details)
      end)
      |> Multi.run(:delete_invitation, fn _, _ ->
        InvitationModel.delete(invitation)
      end)
      |> run_transaction()
    )
  end

  defp existing_user(false, _user, _user_details, invitation) do
    Multi.new()
    |> Multi.run(:delete_invitation, fn _, _ ->
      InvitationModel.delete(invitation)
    end)
    |> run_transaction()
  end

  defp non_existing_user(user_details, invitation) do
    # NOTE: Following two things are happeing inside this transaction:
    # 1) UserCreation from token
    # 3) Invitation Record Deletions
    verify_user(
      Multi.new()
      |> Multi.run(:create_user, fn _, _changes ->
        UserModel.create(user_details)
      end)
      |> Multi.run(:delete_invitation, fn _, _ ->
        InvitationModel.delete(invitation)
      end)
      |> Multi.run(:add_group_and_policies, fn _, %{create_user: user} ->
        add_group_and_policies(user, user_details)
      end)
      |> run_transaction()
    )
  end

  defp add_group_and_policies(user, user_details) do
    policy_ids = Policy.extract_policies(user_details.policies)
    group_ids = UserGroup.extract_groups(user_details.group_ids)

    user_policy_params =
      Enum.reduce(policy_ids, [], fn policy_id, acc ->
        acc ++ [%{user_id: user.id, policy_id: policy_id}]
      end)

    user_group_params =
      Enum.reduce(group_ids, [], fn group_id, acc ->
        acc ++ [%{user_id: user.id, user_group_id: group_id}]
      end)

    Repo.insert_all(UserPolicy, user_policy_params)
    Repo.insert_all(GroupUser, user_group_params)
    {:ok, user}
  end

  defp run_transaction(multi_query) do
    result = Repo.transaction(multi_query)

    case result do
      {:ok,
       %{
         create_user: user,
         delete_invitation: _delete_invitation,
         add_group_and_policies: _add_group_and_policies
       }} ->
        {:ok, user}

      {:ok, %{update_user: user, delete_invitation: _delete_invitation}} ->
        {:ok, user}

      {:ok, %{delete_invitation: _delete_invitation}} ->
        {:error, %{error: "User already exists"}}

      {:error, _failed_operation, failed_value, _changes_so_far} ->
        {:error, failed_value}
    end
  end

  defp verify_error_changeset({:error, changeset}) do
    {:error, %{error: extract_changeset_error(changeset)}}
  end

  defp mark_invitation_token_as_invalid({:ok, _data}) do
    {:error, %{error: resp_msg(:invitation_token_expired)}}
  end

  defp mark_invitation_token_as_invalid({:error, _data}) do
    {:error, %{error: resp_msg(:unable_to_mark_invitation_invalid)}}
  end

  def user_create_es(params) do
    create_function = fn ->
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

    retry(create_function)
  end

  defp verify_user({:ok, user_data}) do
    user_create_es(user_data)
    {:ok, user_data}
  end

  defp verify_user({:error, data}) do
    {:error, %{error: extract_changeset_error(data)}}
  end

  defp retry(function) do
    GenRetry.retry(function, retries: 3, delay: 10_000)
  end
end
