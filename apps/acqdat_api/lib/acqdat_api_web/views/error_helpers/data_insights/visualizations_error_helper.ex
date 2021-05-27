defmodule AcqdatApiWeb.DataInsights.VisualizationsErrorHelper do
  def error_message(:resource_not_found) do
    %{
      title: "Invalid entity ID",
      error: "Visualization with this ID doesn't exists",
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

  def error_message(:export_error, message) do
    %{
      title: "Problem while exporting visualizations",
      error: message,
      source: nil
    }
  end
end
