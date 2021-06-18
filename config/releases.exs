import Config

secret_key_base = System.fetch_env!("SECRET_KEY_BASE")
app_iot_port = System.fetch_env!("APP_IOT_PORT")
app_api_port = System.fetch_env!("APP_API_PORT")
app_hostname = System.fetch_env!("APP_HOSTNAME")
db_user = System.fetch_env!("DB_USER")
db_password = System.fetch_env!("DB_PASSWORD")
db_host = System.fetch_env!("DB_HOST")
elastic_search_host = System.fetch_env!("ELASTIC_SEARCH_HOST")
db_port = System.fetch_env!("DB_PORT")
mqtt_host = System.fetch_env!("MQTT_HOST")
mqtt_port = System.fetch_env!("MQTT_PORT")
twilio_account_sid = System.fetch_env!("TWILIO_ACCOUNT_SID")
twilio_auth_token = System.fetch_env!("TWILIO_AUTH_TOKEN")

config :acqdat_iot, AcqdatIotWeb.Endpoint, server: true

config :acqdat_api, AcqdatApiWeb.Endpoint,
  server: true,
  check_origin: [
    "https://mads.netlify.app",
    "https://mads.netlify.com",
    "https://mads-staging.netlify.app",
    "https://mads-staging.netlify.com",
    "https://studio.mads-iot.com"
    ]

# Configure Guardian
config :acqdat_api, AcqdatApiWeb.Guardian,
  issuer: "acqdat_api",
  secret_key: System.get_env("GUARDIAN_API_KEY")

# Configure Guardian
config :acqdat_iot, AcqdatIotWeb.Guardian,
  issuer: "acqdat_iot",
  secret_key: System.get_env("GUARDIAN_IOT_KEY")

# AWS configuration for Image storage.
config :arc,
  asset_host: "https://datakrew-image.s3.ap-south-1.amazonaws.com",
  storage: Arc.Storage.S3,
  bucket: {:system, "AWS_S3_BUCKET"}

# virtual_host: true
config :ex_aws,
  access_key_id: [{:system, "AWS_ACCESS_KEY_ID"}, :instance_role],
  secret_access_key: [{:system, "AWS_SECRET_ACCESS_KEY"}, :instance_role],
  region: "ap-south-1"

config :acqdat_iot,
  app_port: app_iot_port

config :acqdat_api,
  app_port: app_api_port

config :acqdat_iot,
  app_hostname: app_hostname

config :acqdat_api,
  app_hostname: app_hostname

# Configure your database
config :acqdat_core, AcqdatCore.Repo,
  username: db_user,
  password: db_password,
  database: "acqdat_core_dev",
  hostname: db_host,
  port: db_port,
  pool_size: 40

config :tirexs, :uri, elastic_search_host

config :arc,
  asset_host: "https://datakrew-image.s3.ap-south-1.amazonaws.com",
  storage: Arc.Storage.S3,
  bucket: {:system, "AWS_S3_BUCKET"}

# virtual_host: true

config :ex_aws,
  access_key_id: [{:system, "AWS_ACCESS_KEY_ID"}, :instance_role],
  secret_access_key: [{:system, "AWS_SECRET_ACCESS_KEY"}, :instance_role],
  region: "ap-south-1"

config :google_maps,
  api_key: System.get_env("GOOGLE_SECRET_KEY")

# Configure mailer using Thoughtbot/Bamboo
config :acqdat_core, AcqdatCore.Mailer,
  adapter: Bamboo.SendGridAdapter,
  api_key: System.get_env("SENDGRID_KEY")

config :acqdat_core, :mqtt_broker,
  host: mqtt_host,
  port: mqtt_port


# Configures twilio
config :ex_twilio,
  account_sid: twilio_account_sid,
  auth_token: twilio_auth_token
