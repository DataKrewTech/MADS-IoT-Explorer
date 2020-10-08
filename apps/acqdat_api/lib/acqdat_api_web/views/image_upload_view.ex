defmodule AcqdatApiWeb.ImageUploadView do
  use AcqdatApiWeb, :view

  def render("show.json", %{url: url}) do
    %{
      url: url
    }
  end
end
