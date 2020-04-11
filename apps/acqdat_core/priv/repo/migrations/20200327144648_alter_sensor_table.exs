defmodule AcqdatCore.Repo.Migrations.AlterSensorTable do
  use Ecto.Migration

  def up do
    alter table("acqdat_sensors") do
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
      remove(:slug)
      remove(:parent_type)
      remove(:parent_id)
      remove(:org_id)
      remove(:gateway_id)
      remove(:parameters)
    end
  end
end
