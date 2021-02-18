defmodule AcqdatApiWeb.DataCruncher.DataCruncherErrorHelper do
  def error_message(:tasks, :resource_not_found) do
    %{
      title: "Invalid entity ID",
      error: "Task with this ID does not exists",
      source: nil
    }
  end

  def error_message(:components, :resource_not_found) do
    %{
      title: "Invalid entity ID",
      error: "Problem with indexing of components",
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
