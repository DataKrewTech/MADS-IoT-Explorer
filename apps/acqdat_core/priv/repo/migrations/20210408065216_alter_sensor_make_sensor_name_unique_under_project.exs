defmodule AcqdatCore.Repo.Migrations.AlterSensorMakeSensorNameUniqueUnderProject do
  use Ecto.Migration

  def change do
    create unique_index("acqdat_sensors", [:name, :parent_id, :project_id])
  end
end
