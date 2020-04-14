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
    post "/validate-token", AuthController, :validate_token
    post "/sign-out", AuthController, :sign_out

    resources "/orgs", OrganisationController, only: [:show]
    # NOTE: Kept widgets resources out of organisation_scope currently
    resources "/widgets", Widgets.WidgetController,
      only: [:create, :update, :delete, :index, :show]
  end

  # NOTE: Please add resources here, only if they needs to be scoped by organisation
  scope "/orgs/:org_id", AcqdatApiWeb do
    pipe_through [:api, :api_bearer_auth, :api_ensure_auth]
    resources "/widget-type", Widgets.WidgetTypeController,
      only: [:create, :update, :delete, :index, :show]

    resources "/users", UserController, only: [:show] do
      resources "/settings", UserSettingController, only: [:create, :update], as: :settings
    end

    resources "/user_widgets", Widgets.UserController,
      only: [:index, :create],
      as: :user_widgets
  end

  # TODO: Need to remove this scope, after everything is moved to new routes
  scope "/", AcqdatApiWeb do
    get "/search", Widgets.WidgetController, :search_widget

    resources "/sensor", SensorController, only: [:create, :update, :delete, :index, :show]

    resources "/digital-twin", DigitalTwinController,
      only: [:create, :update, :delete, :index, :show]
  end

  # TODO: Need to remove this scope later, and clean test-cases also
  scope "/tl-mgmt", AcqdatApiWeb do
    pipe_through [:api, :api_bearer_auth, :api_ensure_auth]
    post("/employee/identify", ToolManagementController, :verify_employee)
    post("/tool-transaction", ToolManagementController, :tool_transaction)
    post("/employees", ToolManagementController, :list_employees)
    post("/verify-tool", ToolManagementController, :verify_tool)
    post("/employee-tool-issue-status", ToolManagementController, :employee_tool_issue_status)
    post("/tool-box-status", ToolManagementController, :tool_box_status)

    scope "/", ToolManagement do
      resources "/employee", EmployeeController, only: [:create, :update, :delete, :index, :show]
      resources "/tool-box", ToolBoxController, only: [:create, :update, :delete, :index, :show]
      resources "/tools", ToolController, only: [:create, :update, :delete, :index, :show]
      resources "/tool-type", ToolTypeController, only: [:create, :update, :delete, :index, :show]
    end
  end
end
