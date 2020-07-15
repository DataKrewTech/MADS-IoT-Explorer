defmodule AcqdatCore.Repo.Migrations.EnableTimescaleExtensions do
  use Ecto.Migration

  def up do
    # INFO:: Before running this migration, we need to setup timescale db: Please follow this https://docs.timescale.com/latest/getting-started/installation
    execute("CREATE EXTENSION IF NOT EXISTS timescaledb CASCADE")
  end

  def down do
    execute("DROP EXTENSION IF EXISTS timescaledb CASCADE")
  end
end
