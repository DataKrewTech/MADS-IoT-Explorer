use Mix.Config

# We don't run a server during test. If one is required,
# you can enable the server option below.
config :acqdat_iot, AcqdatApiWeb.Endpoint,
  http: [port: 4003],
  server: false

config :acqdat_api, AcqdatIotWeb.Endpoint,
  http: [port: 4004],
  server: false

# Configure Guardian
config :acqdat_api, AcqdatApiWeb.Guardian,
  issuer: "acqdat_api",
  secret_key: "y3jw57GEKtRZJrTPEl6T2p4GHfPZtr5XuF9+DK04cH/8FkMYPy0xbeH6YXbuSj1E"

# Configure Guardian
config :acqdat_iot, AcqdatIotWeb.Guardian,
  issuer: "acqdat_iot",
  secret_key: "y3jw57GEKtRZJrTPEl6T2p4GHfPZtr5XuF9+DK04cH/8FkMYPy0xbeH6YXbuSj1E"

# Print only warnings and errors during test
config :logger, level: :warn

# Configure your database
config :acqdat_core, AcqdatCore.Repo,
  username: "postgres",
  password: "postgres",
  database: "acqdat_core_test",
  hostname: System.get_env("DB_HOST", "localhost"),
  pool: Ecto.Adapters.SQL.Sandbox

# settings to be used if db connections are failing
# queue_target: 1500,
# queue_interval: 1000

config :tirexs, :uri, System.get_env("ELASTIC_SEARCH_HOST", "http://localhost:9200")

config :argon2_elixir,
  t_cost: 1,
  m_cost: 8

config :acqdat_core, AcqdatCore.Mailer, adapter: Bamboo.TestAdapter

config :vernemq_mads_plugin, read_repo: AcqdatCore.Repo

# Dashboard export URL
config :acqdat_api,
       :frontend_url,
       System.get_env("DASHBOARD_URL", "https://mads.netlify.app/dashboards/")

# salt
config :acqdat_core,
       :secret_salt,
       System.get_env(
         "SECRET_KEY_BASE",
         "i6gwFKNscK4NSgptoHjMsYjmbUgFLKzehE6EBUMOkZpWF5h7Ac+J+IT9z5XVtK/d"
       )
