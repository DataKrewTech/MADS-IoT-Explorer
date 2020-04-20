defmodule AcqdatCore.Mailer.UserInvitationEmailTest do
  use ExUnit.Case
  use AcqdatCore.DataCase
  use Bamboo.Test

  import AcqdatCore.Support.Factory
  alias AcqdatCore.Mailer.UserInvitationEmail
  alias AcqdatCore.Mailer

  test "send email" do
    user = insert(:user)
    invitation_details = %{"email" => "demo@demo.demo", "inviter_email" => "test@test.test"}

    email = UserInvitationEmail.email(user, invitation_details)
    email |> Mailer.deliver_now()
    assert_delivered_email(email)
  end
end
