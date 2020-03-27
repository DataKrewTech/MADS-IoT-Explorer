defmodule AcqdatCore.Repo.Migrations.AlterSensorTable do
  use Ecto.Migration

  def up do
    drop unique_index(:acqdat_sensors, [:name, :device_id], name: :unique_sensor_per_device)
    drop constraint("acqdat_sensors", "acqdat_sensors_device_id_fkey")
    drop constraint("acqdat_sensors", "acqdat_sensors_sensor_type_id_fkey")
    
    alter table("acqdat_sensors") do
      remove(:device_id)
      remove(:sensor_type_id)
      add(:slug, :string, null: false)
      add(:parent_type, :string)
      add(:parent_id, :integer)
      add(:org_id, references("acqdat_organisation", on_delete: :delete_all), null: false)
      add(:gateway_id, references("acqdat_gateway", on_delete: :delete_all))
      add(:parameters, {:array, :map})
    end

    create unique_index("acqdat_sensors", [:slug])
  end

  def down do
    drop unique_index(:acqdat_sensors, [:slug])
    drop constraint("acqdat_sensors", "acqdat_sensors_org_id_fkey")
    drop constraint("acqdat_sensors", "acqdat_sensors_gateway_id_fkey")

    alter table("acqdat_sensors") do
      add(:device_id, references("acqdat_devices", on_delete: :delete_all), null: false)
      add(:sensor_type_id, references("acqdat_sensor_types", on_delete: :restrict), null: false)
      remove(:slug)
      remove(:parent_type)
      remove(:parent_id)
      remove(:org_id)
      remove(:gateway_id)
      remove(:parameters)
    end

    create unique_index("acqdat_sensors", [:name, :device_id], name: :unique_sensor_per_device)
  end
end
