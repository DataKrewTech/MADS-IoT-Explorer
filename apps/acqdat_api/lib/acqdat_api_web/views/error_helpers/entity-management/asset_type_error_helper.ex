defmodule AcqdatApiWeb.EntityManagement.AssetTypeErrorHelper do
  def error_message(:resource_not_found) do
    %{
      title: "Invalid entity ID",
      error: "Either Asset Type or Project or Organisation with this ID doesn't exists",
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

  def error_message(:asset_association, message) do
    %{
      title: "Asset is associated with this asset type",
      error: message,
      source: nil
    }
  end
end
