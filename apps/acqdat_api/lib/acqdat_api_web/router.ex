defmodule AcqdatApiWeb.Router do
  use AcqdatApiWeb, :router

  if Mix.env() == :dev do
    # If using Phoenix
    forward("/sent_emails", Bamboo.SentEmailViewerPlug)
  end

  pipeline :api_bearer_auth do
    plug(AcqdatApiWeb.BearerAuthPipeline)
  end

  pipeline :api_ensure_auth do
    plug(AcqdatApiWeb.EnsureAuthPipeline)
  end

  pipeline :api do
    plug(:accepts, ["json", "json-api"])
  end

  scope "/", AcqdatApiWeb do
    pipe_through(:api)

    post("/sign-in", AuthController, :sign_in)
    post("/orgs/:org_id/users", RoleManagement.UserController, :create)
  end

  scope "/", AcqdatApiWeb do
    pipe_through [:api, :api_bearer_auth, :api_ensure_auth]
    post "/validate-token", AuthController, :validate_token
    post "/sign-out", AuthController, :sign_out

    resources "/roles", RoleManagement.RoleController, only: [:index]

    resources "/orgs", EntityManagement.OrganisationController, only: [:show]
    resources "/apps", AppController, only: [:index]
    get("/orgs/:id/apps", EntityManagement.OrganisationController, :get_apps, as: :org_apps)

    # NOTE: Kept widgets resources out of organisation_scope currently
    resources "/widgets", Widgets.WidgetController,
      only: [:create, :update, :delete, :index, :show]

    resources "/widget-type", Widgets.WidgetTypeController,
      only: [:create, :update, :delete, :index, :show]

    get "/widgets/search", Widgets.WidgetController, :search_widget

    resources("/digital-twin", DigitalTwinController,
      only: [:create, :update, :delete, :index, :show]
    )
  end

  # NOTE: Please add resources here, only if they needs to be scoped by organisation
  scope "/orgs/:org_id", AcqdatApiWeb do
    pipe_through [:api, :api_bearer_auth, :api_ensure_auth]
    resources "/asset-types", AssetTypeController, only: [:create]
    resources "/users", RoleManagement.UserController, only: [:show, :update, :index] do
      resources "/settings", RoleManagement.UserSettingController,
        only: [:create, :update],
        as: :settings

    get "/users/search", RoleManagement.UserController, :search_users

    scope "/", RoleManagement do
      resources("/teams", TeamController, only: [:create, :index, :update])
      put("/teams/:id/assets", TeamController, :update_assets, as: :update_team_assets)
      put("/teams/:id/apps", TeamController, :update_apps, as: :update_team_apps)
      put("/teams/:id/members", TeamController, :update_members, as: :update_team_members)
    end

    scope "/", RoleManagement do
      put("/users/:id/assets", UserController, :assets, as: :user_assets)
      put("/users/:id/apps", UserController, :apps, as: :user_apps)

      resources "/invitations", InvitationController, only: [:create, :update, :index, :delete]
    end
    post("/projects/:project_id/entities", EntityManagement.EntityController, :update_hierarchy)
    get("/projects/:project_id/entities", EntityManagement.EntityController, :fetch_hierarchy)

    get "/projects/:project_id/assets/search", EntityManagement.AssetController, :search_assets

    scope "/projects/:project_id", EntityManagement do
      resources "/assets", AssetController, only: [:create, :show, :update, :delete, :index]
      resources "/sensors", SensorController, only: [:create, :update, :delete, :index, :show]
      resources "/sensor_type", SensorTypeController, only: [:create, :index, :delete, :update]
    end

    resources "/users", UserController, only: [:show, :update, :index] do
      resources "/settings", UserSettingController, only: [:create, :update], as: :settings
      resources "/widgets", Widgets.UserWidgetController, only: [:index, :create], as: :widgets
    end
  end

  # TODO: Need to remove this scope later, and clean test-cases also
  scope "/tl-mgmt", AcqdatApiWeb do
    pipe_through([:api, :api_bearer_auth, :api_ensure_auth])
    post("/employee/identify", ToolManagementController, :verify_employee)
    post("/tool-transaction", ToolManagementController, :tool_transaction)
    post("/employees", ToolManagementController, :list_employees)
    post("/verify-tool", ToolManagementController, :verify_tool)
    post("/employee-tool-issue-status", ToolManagementController, :employee_tool_issue_status)
    post("/tool-box-status", ToolManagementController, :tool_box_status)

    scope "/", ToolManagement do
      resources("/employee", EmployeeController, only: [:create, :update, :delete, :index, :show])
      resources("/tool-box", ToolBoxController, only: [:create, :update, :delete, :index, :show])
      resources("/tools", ToolController, only: [:create, :update, :delete, :index, :show])

      resources("/tool-type", ToolTypeController, only: [:create, :update, :delete, :index, :show])
    end
  end
end
