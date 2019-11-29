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
    resources "/sensor_type", SensorTypeController, only: [:create, :update, :delete, :index]
    resources "/device", DeviceController, only: [:create, :update, :delete, :index]
    resources "/sensor", SensorController, only: [:create, :update, :delete, :index]
    get "/sensor/:device_id", SensorController, :sensor_by_criteria
    resources "/policies", NotificationPolicyController, only: [:index]

    resources "/sensor_notification", SensorNotificationController,
      only: [:create, :update, :delete, :index]
  end
end
