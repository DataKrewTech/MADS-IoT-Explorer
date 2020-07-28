defmodule AcqdatCore.Mailer.UserInvitationEmail do
  use Bamboo.Phoenix, view: AcqdatCore.EmailView
  import Bamboo.Email

  @subject "DataKrew Invitation"

  def email(current_user, invitation_details) do
    {:ok, to_address} = Map.fetch(invitation_details, "email")
    {:ok, from_address} = Map.fetch(invitation_details, "inviter_email")

    new_email()
    |> from(from_address)
    |> to(to_address)
    |> subject(@subject)
    |> put_html_layout({AcqdatCore.EmailView, "email.html"})
    |> render("user_invitation_email.html",
      invitation_details: invitation_details,
      user: current_user
    )
  end
end
