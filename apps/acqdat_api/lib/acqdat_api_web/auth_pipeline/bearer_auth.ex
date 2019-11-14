defmodule AcqdatApiWeb.BearerAuthPipeline do
  use Guardian.Plug.Pipeline,
    otp_app: :acqdat_api,
    module: AcqdatApiWeb.Guardian,
    error_handler: AcqdatApiWeb.ErrorHandler

  plug Guardian.Plug.VerifyHeader, realm: "Bearer"
  plug Guardian.Plug.LoadResource, allow_blank: true
end
