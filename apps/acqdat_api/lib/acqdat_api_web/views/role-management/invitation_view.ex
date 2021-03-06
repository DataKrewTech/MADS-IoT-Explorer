defmodule AcqdatApiWeb.RoleManagement.InvitationView do
  use AcqdatApiWeb, :view
  alias AcqdatApiWeb.RoleManagement.InvitationView
  alias AcqdatApiWeb.RoleManagement.RoleView
  alias AcqdatCore.Model.RoleManagement.UserGroup

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
    user_group =
      case invitation.group_ids do
        nil -> []
        _ -> UserGroup.return_multiple_user_groups(invitation.group_ids)
      end

    %{
      id: invitation.id,
      email: invitation.email,
      token_valid: invitation.token_valid,
      assets: (invitation.asset_ids || []) |> Enum.map(fn id -> %{id: id} end),
      apps: (invitation.app_ids || []) |> Enum.map(fn id -> %{id: id} end),
      role: render_one(invitation.role, RoleView, "role.json"),
      inviter: render_one(invitation.inviter, InvitationView, "user.json"),
      policies: render_many(invitation.policies, InvitationView, "policy.json"),
      user_group: render_many(user_group, InvitationView, "user_group.json")
    }
  end

  def render("user_group.json", %{invitation: user_group}) do
    %{
      id: user_group.id,
      name: user_group.name,
      policies: render_many(user_group.policies, InvitationView, "policy.json")
    }
  end

  def render("policy.json", %{
        invitation: %{"action" => action, "app" => app, "feature" => feature}
      }) do
    %{
      action: action,
      app: app,
      feature: feature
    }
  end

  def render("policy.json", %{invitation: %{action: action, app: app, feature: feature}}) do
    %{
      action: action,
      app: app,
      feature: feature
    }
  end

  def render("user.json", %{invitation: inviter}) do
    %{
      id: inviter.id,
      email: inviter.user_credentials.email
    }
  end
end
