defmodule AcqdatApiWeb.EnsureAuthPipeline do
  use Guardian.Plug.Pipeline,
    otp_app: :acqdat_api,
    module: AcqdatApiWeb.Guardian,
    error_handler: AcqdatApiWeb.ErrorHandler

  plug Guardian.Plug.EnsureAuthenticated
end
