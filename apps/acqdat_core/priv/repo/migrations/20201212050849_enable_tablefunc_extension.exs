defmodule AcqdatCore.Repo.Migrations.EnableTablefuncExtension do
  use Ecto.Migration

  def up do
    # INFO:: To call the crosstab function to generate pivot table, we need to first enable the tablefunc extension
    execute("CREATE EXTENSION IF NOT EXISTS tablefunc")
  end

  def down do
    execute("DROP EXTENSION IF EXISTS tablefunc")
  end
end
