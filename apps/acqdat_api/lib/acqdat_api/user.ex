defmodule AcqdatApi.User do
  alias AcqdatCore.Model.User, as: UserModel
  alias AcqdatCore.Model.Invitation, as: InvitationModel
  alias AcqdatCore.Schema.Invitation
  import AcqdatApiWeb.Helpers

  def get(user_id) do
    UserModel.get(user_id)
  end

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
      last_name: last_name
    } = attrs

    user_details =
      %{}
      |> Map.put(:password, password)
      |> Map.put(:password_confirmation, password_confirmation)
      |> Map.put(:first_name, first_name)
      |> Map.put(:last_name, last_name)

    fetch_existing_invitation(token, user_details)
  end

  defp fetch_existing_invitation(token, user_details) do
    validate_invitation(InvitationModel.get_by_token(token), user_details)
  end

  defp validate_invitation(
         %Invitation{
           asset_ids: asset_ids,
           app_ids: app_ids,
           email: email,
           org_id: org_id,
           role_id: role_id
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

    verify_user(
      UserModel.create(user_details),
      invitation
    )
  end

  defp validate_invitation(nil, _user_details) do
    {:error, %{error: "Invitation doesn't exist"}}
  end

  defp verify_user({:ok, user}, invitation) do
    InvitationModel.delete(invitation)
    {:ok, user}
  end

  defp verify_user({:error, user}, _invitation) do
    {:error, %{error: extract_changeset_error(user)}}
  end
end
