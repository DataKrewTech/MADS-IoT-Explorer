defmodule AcqdatApiWeb.DataCruncher.EntityView do
  use AcqdatApiWeb, :view

  def render("valid_token.json", %{token: token}) do
    %{
      token: token
    }
  end
end
