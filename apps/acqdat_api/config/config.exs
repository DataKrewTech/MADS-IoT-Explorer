# This file is responsible for configuring your application
# and its dependencies with the aid of the Mix.Config module.
#
# This configuration file is loaded before any dependency and
# is restricted to this project.

# General application configuration
use Mix.Config

# Configures the endpoint
config :acqdat_api, AcqdatApiWeb.Endpoint,
  url: [host: "localhost"],
  secret_key_base: "i6gwFKNscK4NSgptoHjMsYjmbUgFLKzehE6EBUMOkZpWF5h7Ac+J+IT9z5XVtK/d",
  render_errors: [view: AcqdatApiWeb.ErrorView, accepts: ~w(json)],
  pubsub: [name: AcqdatApi.PubSub, adapter: Phoenix.PubSub.PG2]


# Configures Elixir's Logger
config :logger, :console,
  format: "$time $metadata[$level] $message\n",
  metadata: [:request_id]

# Use Jason for JSON parsing in Phoenix
config :phoenix, :json_library, Jason

# Import environment specific config. This must remain at the bottom
# of this file so it overrides the configuration defined above.
import_config "#{Mix.env()}.exs"
