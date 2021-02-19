defmodule AcqdatApiWeb.RoleManagement.InvitationErrorHelper do
  def error_message(:create_invitation, message) do
    %{
      title: "Error while Inviting",
      error: message,
      source: nil
    }
  end

  def error_message(:resource_not_found) do
    %{
      title: "Invalid email or Invitation ID",
      error:
        "Either Invitation with this ID doesn't exists or User already exists with this email address",
      source: nil
    }
  end

  def error_message(:unauthorized) do
    %{
      title: "Unauthorized Access",
      error: "You are not allowed to perform this action.",
      source: nil
    }
  end
end
