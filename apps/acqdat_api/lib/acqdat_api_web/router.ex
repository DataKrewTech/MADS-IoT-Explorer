defmodule AcqdatApiWeb.Router do
  use AcqdatApiWeb, :router

  if Mix.env() == :dev do
    # If using Phoenix
    forward "/sent_emails", Bamboo.SentEmailViewerPlug
  end

  pipeline :api_bearer_auth do
    plug AcqdatApiWeb.BearerAuthPipeline
  end

  pipeline :api_ensure_auth do
    plug AcqdatApiWeb.EnsureAuthPipeline
  end

  pipeline :api do
    plug :accepts, ["json", "json-api"]
  end

  scope "/", AcqdatApiWeb do
    pipe_through :api

    post "/sign-in", AuthController, :sign_in
  end

  scope "/", AcqdatApiWeb do
    pipe_through [:api, :api_bearer_auth, :api_ensure_auth]
    post "/refresh", AuthController, :refresh_token
    post "/sign-out", AuthController, :sign_out
  end
end
