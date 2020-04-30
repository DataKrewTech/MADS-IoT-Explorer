defmodule AcqdatApiWeb.ResMessages do
  @moduledoc """
  It contains mapping of all the Generic Res Messages of APIs.
  """

  def resp_msg(message) do
    case message do
      :invited_success ->
        "Send invitation to the user successfully, They will receive email after sometime!"

      :reinvitation_success ->
        "Send Reinvitation to the user successfully, They will receive email after sometime!"

      :invitation_deleted_successfully ->
        "Invitation deleted successfully!"

      :invitation_deletion_error ->
        "unable to delete invitation"

      :invitation_token_expired ->
        "Invitation Token has expired"

      :invalid_invitation_token ->
        "Invalid Invitation Token"

      :invitation_is_not_valid ->
        "Invitation is Invalid"

      :unable_to_mark_invitation_invalid ->
        "Unable to mark Token as Invalid"
    end
  end
end
