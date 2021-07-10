defmodule AcqdatApiWeb.RoleManagement.RequestsErrorHelper do
  def error_message(:resource_not_found) do
    %{
      title: "Invalid Request ID",
      error: "Request with this ID doesn't exists",
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
