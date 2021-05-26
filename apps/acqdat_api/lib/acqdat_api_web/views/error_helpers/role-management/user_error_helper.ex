defmodule AcqdatApiWeb.RoleManagement.UserErrorHelper do
  def error_message(:create_user_error, message) do
    %{
      title: "Error with creation of user",
      error: message,
      source: nil
    }
  end

  def error_message(:resource_not_found) do
    %{
      title: "Invalid entity ID",
      error: "Either User or Organisation with this ID doesn't exists",
      source: nil
    }
  end

  def error_message(:forbidden) do
    %{
      title: "Action not allowed",
      error: "Only admins can delete other users",
      source: %{role: %{message: "Not an admin"}}
    }
  end

  def error_message(:unauthorized) do
    %{
      title: "Unauthorized Access",
      error: "You are not allowed to perform this action.",
      source: nil
    }
  end

  def error_message(:elasticsearch, %{error: %{reason: message}}) do
    %{
      title: "ElasticSearch Indexing Problem",
      error: message,
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
