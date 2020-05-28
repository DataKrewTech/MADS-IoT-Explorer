defmodule AcqdatCore.Repo.Migrations.AlterSensorType do
  use Ecto.Migration

  def up do
    #sensor type alteration
    drop constraint("acqdat_sensor_types", "acqdat_sensor_types_org_id_fkey")
    alter table("acqdat_sensor_types") do
      add(:project_id, references("acqdat_projects", on_delete: :restrict), null: false)
      add(:generated_by, GeneratedBy.type(), default: 0)
      modify(:org_id, references("acqdat_organisation", on_delete: :restrict), null: false)
    end

    drop unique_index(:acqdat_sensor_types, [:name, :org_id])
    create unique_index(:acqdat_sensor_types, [:name, :org_id, :project_id])

    #sensor alteration
    drop constraint("acqdat_sensors", "acqdat_sensors_sensor_type_id_fkey")
    alter table("acqdat_sensors") do
      modify(:sensor_type_id, references("acqdat_sensor_types", on_delete: :restrict))
    end
  end

  def down do
    drop constraint("acqdat_sensor_types", "acqdat_sensor_types_org_id_fkey")
    drop unique_index(:acqdat_sensor_types, [:name, :org_id, :project_id])
    create unique_index(:acqdat_sensor_types, [:name, :org_id])
    alter table("acqdat_sensor_types") do
      remove(:project_id)
      remove(:generated_by)
      modify(:org_id, references("acqdat_organisation", on_delete: :restrict), null: false)
    end

    drop constraint("acqdat_sensors", "acqdat_sensors_sensor_type_id_fkey")
    alter table("acqdat_sensors") do
      modify(:sensor_type_id, references("acqdat_sensor_types", on_delete: :restrict))
    end
  end
end
