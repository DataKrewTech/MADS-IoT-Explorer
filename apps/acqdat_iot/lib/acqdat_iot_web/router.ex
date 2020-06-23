defmodule AcqdatIotWeb.Router do
  use AcqdatIotWeb, :router

  pipeline :api do
    plug :accepts, ["json"]
  end

  scope "/api", AcqdatIotWeb do
    pipe_through :api
  end

  pipeline :verify_gateway do
    plug(AcqdatIotWeb.Plugs.VerifyGateway)
  end

  scope "/orgs/:org_id", AcqdatIotWeb do
    pipe_through :verify_gateway

    scope "/projects/:project_id", DataParser do
      resources "/gateways/:gateway_id/data_dump", DataDumpController, except: [:new, :edit]
    end
  end
end
