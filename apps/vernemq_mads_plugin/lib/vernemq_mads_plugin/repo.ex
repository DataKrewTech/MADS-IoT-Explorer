defmodule VernemqMadsPlugin.Repo do
  use Ecto.Repo,
    otp_app: :vernemq_mads_plugin,
    adapter: Ecto.Adapters.Postgres
end
