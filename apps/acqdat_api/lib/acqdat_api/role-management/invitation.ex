defmodule AcqdatApi.RoleManagement.Invitation do
  import AcqdatApiWeb.Helpers
  import AcqdatApiWeb.ResMessages
  alias AcqdatCore.Model.RoleManagement.Invitation, as: InvitationModel
  alias AcqdatCore.Schema.RoleManagement.Invitation
  alias AcqdatCore.Model.RoleManagement.User, as: UserModel
  alias AcqdatCore.Mailer.UserInvitationEmail
  alias AcqdatCore.Mailer
  alias AcqdatCore.Repo

  defdelegate get_by_token(token), to: InvitationModel

  def create(attrs, current_user) do
    invitation_details = invitation_details_attrs(attrs, current_user)

    org_ids = UserModel.fetch_user_orgs_by_email(invitation_details["email"])

    if org_ids == [] do
      create_invitation(
        InvitationModel.create_invitation(invitation_details),
        invitation_details,
        current_user
      )
    else
      if Enum.member?(org_ids, invitation_details["org_id"]) do
        create_invitation({:user_exists, ""}, "", "")
      else
        invitation_details = Map.put(invitation_details, "type", "existing_user")

        create_invitation(
          InvitationModel.create_invitation(invitation_details),
          invitation_details,
          current_user
        )
      end
    end
  end

  def update(invitation, current_user, group_ids, policies) do
    reinvite_user(
      InvitationModel.update_invitation_token(invitation, %{
        "email" => invitation.email,
        "org_id" => invitation.org_id,
        "token_valid" => true,
        "group_ids" => group_ids,
        "policies" => policies
      }),
      current_user
    )
  end

  def reinvite_user({:ok, invitation}, current_user) do
    reinvitation_details_parsing(invitation, current_user)
    |> send_invite_email(current_user)
    |> show_reinvitation_success_message_to_user()
  end

  def reinvite_user({:error, invitation}, _current_user) do
    {:error, %{error: extract_changeset_error(invitation)}}
  end

  defp invitation_details_attrs(
         %{
           email: email,
           apps: apps,
           assets: assets,
           org_id: org_id,
           role_id: role_id,
           group_ids: group_ids,
           policies: policies
         },
         current_user
       ) do
    app_ids = Enum.map(apps || [], & &1["id"])
    asset_ids = Enum.map(assets || [], & &1["id"])

    %{
      "email" => email,
      "app_ids" => app_ids,
      "asset_ids" => asset_ids,
      "group_ids" => group_ids,
      "policies" => policies,
      "inviter_email" => current_user.user_credentials.email,
      "inviter_name" =>
        "#{current_user.user_credentials.first_name} #{current_user.user_credentials.last_name}",
      "inviter_id" => current_user.id,
      "org_id" => org_id,
      "role_id" => role_id
    }
  end

  defp invitation_details_attrs(
         %{
           email: email,
           org_id: org_id,
           role_id: role_id,
           metadata: metadata,
           type: type
         },
         current_user
       ) do
    %{
      "email" => email,
      "inviter_email" => current_user.user_credentials.email,
      "inviter_name" =>
        "#{current_user.user_credentials.first_name} #{current_user.user_credentials.last_name}",
      "inviter_id" => current_user.id,
      "org_id" => org_id,
      "role_id" => role_id,
      "metadata" => metadata,
      "type" => type
    }
  end

  defp reinvitation_details_parsing(
         %Invitation{
           asset_ids: asset_ids,
           app_ids: app_ids,
           email: email,
           org_id: org_id,
           role_id: role_id,
           token: token
         },
         current_user
       ) do
    %{
      "email" => email,
      "app_ids" => app_ids,
      "asset_ids" => asset_ids,
      "inviter_email" => current_user.user_credentials.email,
      "inviter_name" =>
        "#{current_user.user_credentials.first_name} #{current_user.user_credentials.last_name}",
      "inviter_id" => current_user.id,
      "org_id" => org_id,
      "role_id" => role_id,
      "token" => token
    }
  end

  def delete(invitation) do
    delete_invitation(
      Repo.transaction(fn ->
        invitation = InvitationModel.delete(invitation)
        delete_user(invitation)
        invitation
      end)
    )
  end

  defp delete_user({:ok, %{email: email, org_id: org_id}}) do
    case UserModel.fetch_user_by_email_n_org(email, org_id) do
      nil ->
        {:error, "User not Found in the specified organisation"}

      user ->
        UserModel.delete(user)
    end
  end

  defp delete_invitation({:ok, _invitation}) do
    {:ok, resp_msg(:invitation_deleted_successfully)}
  end

  defp delete_invitation({:error, _invitation}) do
    {:error, resp_msg(:invitation_deletion_error)}
  end

  defp create_invitation({:ok, invitation}, invitation_details, current_user) do
    invitation_details = Map.put(invitation_details, "token", invitation.token)

    invitation_details
    |> send_invite_email(current_user)
    |> show_message_to_user()
  end

  defp create_invitation({:error, invitation}, _invitation_details, _current_user) do
    {:error, %{error: extract_changeset_error(invitation)}}
  end

  defp create_invitation({:user_exists, _invitation}, _invitation_details, _current_user) do
    {:error,
     %{
       error: %{
         error:
           "Parameters provided to perform current action is either not valid or missing or not unique",
         source: %{email: ["user with this email already exists for the specified organisation"]},
         title: "Insufficient or not unique parameters"
       }
     }}
  end

  defp send_invite_email(invitation_details, current_user) do
    UserInvitationEmail.email(current_user, invitation_details)
    |> Mailer.deliver_now()
  end

  defp show_message_to_user(_invitation_details) do
    {:ok, resp_msg(:invited_success)}
  end

  defp show_reinvitation_success_message_to_user(_invitation_details) do
    {:ok, resp_msg(:reinvitation_success)}
  end
end
