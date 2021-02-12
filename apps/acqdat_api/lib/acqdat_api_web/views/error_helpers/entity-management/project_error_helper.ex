defmodule AcqdatApiWeb.EntityManagement.ProjectErrorHelper do
  def error_message(:resource_not_found) do
    %{
      title: "Invalid entity ID",
      error: "Project or Organisation with this ID doesn't exists",
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

  def error_message(:elasticsearch, message) do
    %{
      title: "Problem with elasticsearch",
      error: message,
      source: nil
    }
  end
end
