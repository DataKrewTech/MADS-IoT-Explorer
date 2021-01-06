defmodule AcqdatApiWeb.Router do
  use AcqdatApiWeb, :router
  use Plug.ErrorHandler

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

  pipeline :export_auth do
    plug(AcqdatApiWeb.DashboardExportAuth)
  end

  pipeline :password_reset_auth do
    plug(AcqdatApiWeb.PasswordResetAuth)
  end

  scope "/", AcqdatApiWeb do
    pipe_through(:export_auth)
    get("/dashboards/:dashboard_uuid", DashboardExport.DashboardExportController, :export)

    get(
      "/dashboards/:dashboard_uuid/verify",
      DashboardManagement.DashboardController,
      :exported_dashboard
    )

    get("/details/:dashboard_uuid/panels/:id", DashboardExport.DashboardExportController, :show)
  end

  scope "/", AcqdatApiWeb do
    pipe_through(:password_reset_auth)
    put("/reset_password", RoleManagement.ForgotPasswordController, :reset_password)
  end

  scope "/", AcqdatApiWeb do
    pipe_through(:api)
    post "/verify-token", RoleManagement.InvitationController, :validate_token
    post("/sign-in", AuthController, :sign_in)
    post("/forgot_password", RoleManagement.ForgotPasswordController, :forgot_password)
    post("/orgs/:org_id/users", RoleManagement.UserController, :create)
  end

  scope "/", AcqdatApiWeb do
    pipe_through [:api, :api_bearer_auth, :api_ensure_auth]
    post "/validate-token", AuthController, :validate_token
    post "/sign-out", AuthController, :sign_out
    post "/orgs/:org_id/validate_credentials", AuthController, :validate_credentials

    resources "/roles", RoleManagement.RoleController, only: [:index]

    resources "/orgs", EntityManagement.OrganisationController, only: [:show]
    resources "/apps", AppController, only: [:index]
    get("/orgs/:id/apps", EntityManagement.OrganisationController, :get_apps, as: :org_apps)

    # NOTE: Kept widgets resources out of organisation_scope currently
    get "/widgets/search", Widgets.WidgetController, :search_widget

    get "/widgets/filtered", Widgets.WidgetController, :fetch_all

    resources "/widgets", Widgets.WidgetController,
      only: [:create, :update, :delete, :index, :show]

    resources "/widget-type", Widgets.WidgetTypeController,
      only: [:create, :update, :delete, :index, :show]

    resources("/digital-twin", DigitalTwinController,
      only: [:create, :update, :delete, :index, :show]
    )

    resources "/uploads", ImageUploadController, only: [:create]
  end

  # NOTE: Please add resources here, only if they needs to be scoped by organisation
  scope "/orgs/:org_id", AcqdatApiWeb do
    pipe_through [:api, :api_bearer_auth, :api_ensure_auth]
    post("/dashboards/:dashboard_id/export", DashboardExport.DashboardExportController, :create)

    put(
      "/dashboards/:dashboard_id/export/:dashboard_uuid",
      DashboardExport.DashboardExportController,
      :update
    )

    get(
      "/dashboards/:dashboard_id/export/:dashboard_uuid/show_credentials",
      DashboardExport.DashboardExportController,
      :show_credentials
    )

    resources "/components", DataCruncher.ComponentsController, only: [:index]

    resources "/users", RoleManagement.UserController, only: [:show, :update, :index, :delete] do
      resources "/tasks", DataCruncher.TasksController,
        only: [:create, :index, :show, :update, :delete]

      resources "/settings", RoleManagement.UserSettingController,
        only: [:create, :update],
        as: :settings

      resources "/widgets", Widgets.UserWidgetController, only: [:index, :create], as: :widgets
    end

    get "/search_users", RoleManagement.UserController, :search_users

    scope "/", RoleManagement do
      put("/users/:id/assets", UserController, :assets, as: :user_assets)
      put("/users/:id/apps", UserController, :apps, as: :user_apps)

      resources "/invitations", InvitationController, only: [:create, :update, :index, :delete]
    end

    get "/projects/search", EntityManagement.ProjectController, :search_projects,
      as: :search_projects

    post("/projects/:project_id/entities", EntityManagement.EntityController, :update_hierarchy)
    get("/projects/:project_id/entities", EntityManagement.EntityController, :fetch_hierarchy)
    get("/entities", EntityManagement.EntityController, :fetch_all_hierarchy)

    get("/projects/:project_id/users", EntityManagement.ProjectController, :fetch_project_users)

    get("/archived_projects", EntityManagement.ProjectController, :archived,
      as: :archived_projects
    )

    resources "/projects", EntityManagement.ProjectController,
      only: [:index, :create, :update, :delete, :show]

    scope "/projects/:project_id", IotManager do
      get "/gateways/search", GatewayController, :search_gateways, as: :search_gateways
      put "/gateways/:gateway_id/associate-sensors", GatewayController, :associate_sensors
      resources "/gateways", GatewayController, except: [:new, :edit]
      post "/gateways/:gateway_id/store_commands", GatewayController, :store_commands
      get("/hierarchy", GatewayController, :hierarchy)
      get "/gateways/:gateway_id/data_dump_index", GatewayController, :data_dump_index
    end

    get "/gateways/", IotManager.GatewayController, :all_gateways
    # all the alert apis will be scoped here
    scope "/", Alerts do
      resources "/policies", PolicyController, only: [:index]
      resources "/alert-rules", AlertRulesController, except: [:new, :edit]
      resources "/alert", AlertController, except: [:new, :edit, :create]
      get "/alert_rule_listing", AlertFilterListingController, :alert_rule_listing
      get "/alert_apps", AlertFilterListingController, :alert_app_listing
      get "/alert_status", AlertFilterListingController, :alert_status_listing
    end

    scope "/projects/:project_id", EntityManagement do
      resources "/asset_types", AssetTypeController, only: [:create, :update, :delete, :index]
      get "/assets/search", AssetController, :search_assets, as: :search_assets
      get "/sensors/search", SensorController, :search_sensors, as: :search_sensors

      get "/sensor_type/search", SensorTypeController, :search_sensor_type,
        as: :search_sensor_type

      get "/asset_types/search", AssetTypeController, :search_asset_type, as: :search_asset_type

      resources "/assets", AssetController,
        only: [:create, :show, :update, :delete, :index],
        as: :assets

      resources "/sensors", SensorController, except: [:new, :edit]
      resources "/sensor_type", SensorTypeController, only: [:create, :index, :delete, :update]
    end

    resources "/dashboards", DashboardManagement.DashboardController, except: [:new, :edit]

    scope "/dashboards/:dashboard_id", DashboardManagement do
      resources "/panels", PanelController, except: [:new, :edit]
    end

    scope "/panels/:panel_id", DashboardManagement do
      resources "/command_widgets", CommandWidgetController, except: [:new, :index, :edit]
    end

    get "/command_widget_types",
        DashboardManagement.CommandWidgetController,
        :command_widget_types

    post "/panels/:panel_id/widgets/:widget_id/widget_instances",
         DashboardManagement.WidgetInstanceController,
         :create,
         as: :create_widget_instances

    get "/panels/:panel_id/widgets/:widget_id/widget_instances/:id",
        DashboardManagement.WidgetInstanceController,
        :show,
        as: :show_widget_instances

    delete "/panels/:panel_id/widgets/:widget_id/widget_instances/:id",
           DashboardManagement.WidgetInstanceController,
           :delete,
           as: :delete_widget_instances

    put "/panels/:panel_id/widgets/:widget_id/widget_instances/:id",
        DashboardManagement.WidgetInstanceController,
        :update,
        as: :update_widget_instances

    post("/data_cruncher_token", DataCruncher.EntityController, :fetch_token)
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
