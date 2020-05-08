defmodule AcqdatApiWeb.RoleManagement.InvitationView do
  use AcqdatApiWeb, :view
  alias AcqdatApiWeb.RoleManagement.InvitationView
  alias AcqdatApiWeb.RoleManagement.RoleView

  def render("invite.json", %{message: message}) do
    %{
      status: message
    }
  end

  def render("index.json", invitation) do
    %{
      invitations:
        render_many(invitation.entries, InvitationView, "invitation_with_preloads.json"),
      page_number: invitation.page_number,
      page_size: invitation.page_size,
      total_entries: invitation.total_entries,
      total_pages: invitation.total_pages
    }
  end

  def render("invitation_with_preloads.json", %{invitation: invitation}) do
    %{
      id: invitation.id,
      email: invitation.email,
      token_valid: invitation.token_valid,
      assets: (invitation.asset_ids || []) |> Enum.map(fn id -> %{id: id} end),
      apps: (invitation.app_ids || []) |> Enum.map(fn id -> %{id: id} end),
      role: render_one(invitation.role, RoleView, "role.json"),
      inviter: render_one(invitation.inviter, InvitationView, "user.json")
    }
  end

  def render("user.json", %{invitation: inviter}) do
    %{
      id: inviter.id,
      email: inviter.email
    }
  end
end
