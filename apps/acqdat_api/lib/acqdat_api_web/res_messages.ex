defmodule AcqdatApiWeb.ResMessages do
  @moduledoc """
  It contains mapping of all the Generic Res Messages of APIs.
  """

  def resp_msg(message) do
    case message do
      :invited_success ->
        "Send invitation to the user successfully, They will receive email after sometime!"
    end
  end
end
