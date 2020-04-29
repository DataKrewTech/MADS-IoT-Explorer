defmodule AcqdatApiWeb.ResMessages do
  @moduledoc """
  It contains mapping of all the Generic Res Messages of APIs.
  """

  def resp_msg(message) do
    case message do
      :invited_success ->
        "Send invitation to the user successfully, They will receive email after sometime!"

      :invitation_deleted_successfully ->
        "Invitation deleted successfully!"

      :invitation_deletion_error ->
        "unable to delete invitation"
    end
  end
end
