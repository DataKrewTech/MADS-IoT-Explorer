defmodule AcqdatApiWeb.Alerts.AlertErrorHelper do
  def error_message(:resource_not_found) do
    %{
      title: "Invalid entity ID",
      error: "Either Alert with this ID doesn't exists or you don't have access to it.",
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

defmodule AcqdatApiWeb.Alerts.AlertRuleErrorHelper do
  def error_message(:resource_not_found) do
    %{
      title: "Invalid entity ID",
      error: "Either Alert Rule with this ID doesn't exists or you don't have access to it.",
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
