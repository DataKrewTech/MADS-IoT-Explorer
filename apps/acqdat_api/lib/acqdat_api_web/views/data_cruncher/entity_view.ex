defmodule AcqdatApiWeb.DataCruncher.EntityView do
  use AcqdatApiWeb, :view
  alias AcqdatApiWeb.DataCruncher.EntityView

  def render("valid_token.json", %{token: token}) do
    %{
      token: token
    }
  end
end
