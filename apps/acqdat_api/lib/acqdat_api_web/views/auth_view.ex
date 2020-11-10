defmodule AcqdatApiWeb.AuthView do
  use AcqdatApiWeb, :view

  def render("signin.json", manifest) do
    %{
      access_token: manifest.access_token,
      refresh_token: manifest.refresh_token,
      user_id: manifest.user_id
    }
  end

  def render("validate_token.json", %{data: manifest}) do
    %{
      message: "Authorized",
      access_token: manifest.access_token,
      user_id: manifest.user_id
    }
  end

  def render("signout.json", %{message: message}) do
    %{
      status: message
    }
  end

  def render("delete.json", _) do
    %{ok: true}
  end

  def render("user.json", user) do
    %{
      id: user.id,
      email: user.email
    }
  end
end
