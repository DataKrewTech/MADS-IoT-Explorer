defmodule AcqdatCore.Repo.Migrations.EnableTimescaleExtensions do
  use Ecto.Migration

  def up do
    execute("CREATE EXTENSION IF NOT EXISTS timescaledb CASCADE")
  end

  def down do
    execute("DROP EXTENSION IF EXISTS timescaledb CASCADE")
  end
end
