defmodule AcqdatApiWeb.DashboardManagement.DashboardErrorHelper do
  def error_message(:resource_not_found) do
    %{
      title: "Invalid entity ID",
      error: "Dashboard with this ID does not exists",
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

  def error_message(:redis_error, message) do
    %{
      title: "Problem reading from Redis",
      error: "Either redis instance is not up or there is problem reading from redis.",
      source: nil
    }
  end

  def error_message(:report_error, message) do
    %{
      title: "Problem while generating Report",
      error: message,
      source: nil
    }
  end
end

defmodule AcqdatApiWeb.DashboardManagement.DashboardExportErrorHelper do
  def error_message(:resource_not_found) do
    %{
      title: "Invalid entity ID",
      error: "Resource with this ID does not exists",
      source: nil
    }
  end

  def error_message(:report_error, message) do
    %{
      title: "Problem while generating Report",
      error: message,
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

  def error_message(:updation_error, message) do
    %{
      title: "Updation Error",
      error: message.error,
      source: nil
    }
  end
end
