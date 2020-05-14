defmodule AcqdatApiWeb.EntityManagement.AssetTypeView do
  use AcqdatApiWeb, :view

  def render("asset_type.json", %{asset_type: asset_type}) do
    %{
      type: "Asset Type",
      id: asset_type.id,
      name: asset_type.name,
      description: asset_type.description
    }
  end
end
