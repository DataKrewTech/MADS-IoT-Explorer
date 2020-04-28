defmodule AcqdatApi.Invitation do
  import AcqdatApiWeb.Helpers
  import AcqdatApiWeb.ResMessages
  alias AcqdatCore.Model.Invitation, as: InvitationModel
  alias AcqdatCore.Mailer.UserInvitationEmail
  alias AcqdatCore.Mailer

  def create(attrs, current_user) do
    %{
      email: email,
      apps: apps,
      assets: assets,
      org_id: org_id,
      role_id: role_id
    } = attrs

    app_ids = Enum.map(apps || [], & &1["id"])
    asset_ids = Enum.map(assets || [], & &1["id"])

    invitation_details = %{
      "email" => email,
      "app_ids" => app_ids,
      "asset_ids" => asset_ids,
      "inviter_email" => current_user.email,
      "inviter_id" => current_user.id,
      "org_id" => org_id,
      "role_id" => role_id
    }

    create_invitation(
      InvitationModel.create_invitation(invitation_details),
      invitation_details,
      current_user
    )
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

  defp send_invite_email(invitation_details, current_user) do
    UserInvitationEmail.email(current_user, invitation_details)
    |> Mailer.deliver_now()
  end

  defp show_message_to_user(_invitation_details) do
    {:ok, resp_msg(:invited_success)}
  end
end
