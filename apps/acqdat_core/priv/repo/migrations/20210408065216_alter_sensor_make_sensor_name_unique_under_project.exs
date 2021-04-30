defmodule AcqdatCore.Repo.Migrations.AlterSensorMakeSensorNameUniqueUnderProject do
  use Ecto.Migration

  def up do
    drop unique_index("acqdat_asset", [:name, :parent_id, :org_id])
    create unique_index("acqdat_asset", [:name, :parent_id, :org_id, :project_id])
    create unique_index("acqdat_sensors", [:name, :parent_id, :project_id])
    execute( "create unique index asset_root_unique_name on acqdat_asset (name, parent_id, project_id, coalesce(parent_id, -1));" )
  end

  def down do
    drop unique_index("acqdat_asset", [:name, :parent_id, :org_id, :project_id])
    drop unique_index("acqdat_sensors", [:name, :parent_id, :project_id])
    execute( "drop unique index asset_root_unique_name on acqdat_asset (name, parent_id, project_id, coalesce(parent_id, -1));" )
    create unique_index("acqdat_asset", [:name, :parent_id, :org_id])
  end
end
