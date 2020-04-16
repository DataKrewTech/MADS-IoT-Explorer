defmodule AcqdatApiWeb.InvitationView do
  use AcqdatApiWeb, :view

  def render("invite.json", %{message: message}) do
    %{
      status: message
    }
  end
end
