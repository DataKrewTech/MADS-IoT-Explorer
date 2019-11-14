# This file is responsible for configuring your application
# and its dependencies with the aid of the Mix.Config module.
#
# This configuration file is loaded before any dependency and
# is restricted to this project.

# General application configuration
use Mix.Config

# Configures the API endpoint for frontend
config :acqdat_api, AcqdatApiWeb.Endpoint,
  url: [host: "localhost"],
  secret_key_base: "i6gwFKNscK4NSgptoHjMsYjmbUgFLKzehE6EBUMOkZpWF5h7Ac+J+IT9z5XVtK/d",
  render_errors: [view: AcqdatApiWeb.ErrorView, accepts: ~w(json)],
  pubsub: [name: AcqdatApi.PubSub, adapter: Phoenix.PubSub.PG2]

# Configures API endpoint for IoT
config :acqdat_iot, AcqdatIotWeb.Endpoint,
  url: [host: "localhost"],
  secret_key_base: "yYOb9ox1GX/EnMwCEk6OnTGMMGTac7b/m97D+nH4Si07aOfuP1pOGE8Lhg7lUMkd",
  render_errors: [view: AcqdatIotWeb.ErrorView, accepts: ~w(json)],
  pubsub: [name: AcqdatIot.PubSub, adapter: Phoenix.PubSub.PG2]

# Configures Elixir's Logger
config :logger, :console,
  format: "$time $metadata[$level] $message\n",
  metadata: [:request_id]

# Use Jason for JSON parsing in Phoenix
config :phoenix, :json_library, Jason

# Configure Guardian
config :acqdat_api, AcqdatApiWeb.Guardian,
  issuer: "acqdat_api",
  secret_key: System.get_env("GUARDIAN_API_KEY")

# Configure Guardian
config :acqdat_iot, AcqdatIotWeb.Guardian,
  issuer: "acqdat_iot",
  secret_key: System.get_env("GUARDIAN_IOT_KEY")

# Configure authentication pipeline
config :acqdat_api, AcqdatApiWeb.AuthenticationPipe,
  module: AcqdatApiWeb.Guardian,
  error_handler: AcqdatApiWeb.AuthErrorHandler

# Configure mailer using Thoughtbot/Bamboo
config :acqdat_core, AcqdatCore.Mailer,
  adapter: Bamboo.SendGridAdapter,
  api_key: System.get_env("SENDGRID_KEY")

# Configures JSON API encoding
config :phoenix, :format_encoders, "json-api": Jason

# Configures JSON API mime type
config :mime, :types, %{
  "application/vnd.api+json" => ["json-api"]
}

# Configures Key Format
config :ja_serializer,
  key_format: :underscored,
  page_key: "page",
  page_number_key: "offset",
  page_size_key: "limit",
  page_number_origin: 1,
  page_size: 2

config :acqdat_core,
  ecto_repos: [AcqdatCore.Repo]

# Import environment specific config. This must remain at the bottom
# of this file so it overrides the configuration defined above.
import_config "#{Mix.env()}.exs"
