defmodule AcqdatApi.Invitation do
  alias AcqdatCore.Model.Invitation, as: InvitationModel
  import AcqdatApiWeb.Helpers
  alias AcqdatCore.Model.User, as: UserModel

  def create(attrs) do
    {:ok, current_user} = UserModel.get(1)

    %{
      email: email,
      apps: apps,
      assets: assets
    } = attrs

    app_ids = Enum.map(apps, & &1["id"])
    asset_ids = Enum.map(assets, & &1["id"])

    invitation_details = %{
      "email" => email,
      "app_ids" => app_ids,
      "asset_ids" => asset_ids,
      "inviter_email" => current_user.email,
      "inviter_id" => current_user.id
    }

    invitation_details
    |> InvitationModel.create_invitation()
    |> send_invite_email
  end

  def send_invite_email(attrs) do
    # TODO: Email Sending logic
    {:ok,
     "Send invitation to the user successfully, They will receive the message after sometime!"}
  end
end
