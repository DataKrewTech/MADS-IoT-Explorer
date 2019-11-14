defmodule AcqdatApiWeb.AuthView do
  use AcqdatApiWeb, :view

  def render("signin.json", manifest) do
    %{
      access_token: manifest.access_token,
      refresh_token: manifest.refresh_token,
      user_id: manifest.user_id,
    }
  end

  def render("refresh.json", manifest) do
    %{
      access_token: manifest.token
    }
  end

  def render("delete.json", _) do
    %{ok: true}
  end
end
