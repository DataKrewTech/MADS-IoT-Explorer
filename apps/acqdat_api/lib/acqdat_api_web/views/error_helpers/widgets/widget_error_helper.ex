defmodule AcqdatApiWeb.Widgets.WidgetErrorHelper do
  def error_message(:resource_not_found) do
    %{
      title: "Invalid entity ID",
      error:
        "Either widget or widget type with this ID doesn't exists or you don't have access to it.",
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

  def error_message(:elasticsearch, %{error: %{reason: message}}) do
    %{
      title: "ElasticSearch Indexing Problem",
      error: message,
      source: nil
    }
  end

  def error_message(:elasticsearch, message) do
    %{
      title: "There is some problem with elasticsearch.",
      error: message,
      source: nil
    }
  end
end

defmodule AcqdatApiWeb.Widgets.WidgetTypeErrorHelper do
  def error_message(:resource_not_found) do
    %{
      title: "Invalid entity ID",
      error: "Either widget type with this ID doesn't exists or you don't have access to it.",
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

defmodule AcqdatApiWeb.Widgets.UserWidgetErrorHelper do
  def error_message(:resource_not_found) do
    %{
      title: "Invalid entity ID",
      error: "Either widget or user with this ID doesn't exists or you don't have access to it.",
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

  def confirm_message(:widget_added) do
    %{
      status_code: 200,
      title: "Widget Added",
      detail: "This is successfully added to your workspace.",
      source: nil
    }
  end
end
