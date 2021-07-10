defmodule AcqdatApiWeb.Plug.CORS do
  @moduledoc false

  use Corsica.Router,
    origins: "*",
    log: [rejected: :error],
    allow_credentials: true,
    allow_headers: [
      "content-type",
      "token-type",
      "authorization",
      "invitation-token",
      "auth-token"
    ],
    allow_methods: ["GET", "PUT", "OPTIONS", "DELETE", "PATCH", "POST"],
    max_age: 600

  resource("/*")
end
