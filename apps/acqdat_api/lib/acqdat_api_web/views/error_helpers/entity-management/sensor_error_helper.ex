defmodule AcqdatApiWeb.EntityManagement.SensorErrorHelper do
  def error_message(:resource_not_found) do
    %{
      title: "Invalid entity ID",
      error: "Either Sensor or Project or Organisation with this ID doesn't exists",
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

  def error_message(:iot_data_existence, message) do
    %{
      title: "Sensor contains IOT data",
      error: message,
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
