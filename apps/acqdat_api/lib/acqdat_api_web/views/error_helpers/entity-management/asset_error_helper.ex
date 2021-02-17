defmodule AcqdatApiWeb.EntityManagement.AssetErrorHelper do
  def error_message(:acqdat_asset_slug_index) do
    %{
      title: "Name uniqueness error ",
      error: "No two asset with same name can be under one parent",
      source: nil
    }
  end

  def error_message(:acqdat_asset_name_parent_id_org_id_index) do
    %{
      title: "Name uniqueness error",
      error: "No two asset with same name can be under one parent",
      source: nil
    }
  end

  def error_message(:resource_not_found) do
    %{
      title: "Invalid entity ID",
      error: "Either Asset or Project or Organisation with this ID doesn't exists",
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

  def error_message(:asset_with_child_sensors, message) do
    %{
      title: "Asset contains sensors",
      error: message,
      source: nil
    }
  end

  def error_message(:elasticsearch_error, message) do
    %{
      title: "There is some problem with elasticsearch.",
      error: message,
      source: nil
    }
  end
end
