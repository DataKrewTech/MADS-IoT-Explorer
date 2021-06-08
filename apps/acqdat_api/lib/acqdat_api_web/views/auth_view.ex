defmodule AcqdatApiWeb.AuthView do
  use AcqdatApiWeb, :view
  alias AcqdatApiWeb.EntityManagement.OrganisationView

  def render("signin.json", manifest) do
    %{
      access_token: manifest.access_token,
      email: manifest.email,
      credentials_id: manifest.credentials_id,
      orgs: render_many(manifest.orgs, OrganisationView, "org.json")
    }
  end

  def render("org_signin.json", manifest) do
    %{
      access_token: manifest.access_token,
      refresh_token: manifest.refresh_token,
      user_id: manifest.user_id
    }
  end

  def render("signup.json", request) do
    %{
      id: request.id,
      email: request.email,
      first_name: request.first_name,
      last_name: request.last_name,
      org_name: request.org_name,
      org_url: request.org_url,
      phone_number: request.phone_number,
      status: request.status,
      user_metadata: request.user_metadata
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
      email: user.user_credentials.email
    }
  end
end
