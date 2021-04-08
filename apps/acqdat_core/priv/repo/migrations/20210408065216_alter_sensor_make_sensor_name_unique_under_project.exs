defmodule AcqdatCore.Repo.Migrations.AlterSensorMakeSensorNameUniqueUnderProject do
  use Ecto.Migration

  def up do
    drop unique_index("acqdat_asset", [:name, :parent_id, :org_id])
    create unique_index("acqdat_asset", [:name, :parent_id, :org_id, :project_id])
    create unique_index("acqdat_sensors", [:name, :parent_id, :project_id])
  end

  def down do
    drop unique_index("acqdat_asset", [:name, :parent_id, :org_id, :project_id])
    drop unique_index("acqdat_sensors", [:name, :parent_id, :project_id])
    create unique_index("acqdat_asset", [:name, :parent_id, :org_id])
  end
end
