defmodule AcqdatCore.Repo.Migrations.AddProjectAssociations do
  use Ecto.Migration

   def up do
    alter table("acqdat_asset") do
      add(:project_id, references("acqdat_projects", on_delete: :delete_all), null: false)
    end

    alter table("acqdat_sensors") do
      add(:project_id, references("acqdat_projects", on_delete: :delete_all), null: false)
    end

    alter table("acqdat_gateway") do
      add(:project_id, references("acqdat_projects", on_delete: :delete_all), null: false)
    end

  end

  def down do
    drop constraint("acqdat_gateway", "acqdat_gateway_project_id_fkey")
    drop constraint("acqdat_sensors", "acqdat_sensors_project_id_fkey")
    drop constraint("acqdat_asset", "acqdat_asset_project_id_fkey")

    alter table("acqdat_gateway") do
      remove(:project_id)
    end

    alter table("acqdat_sensors") do
      remove(:project_id)
    end

    alter table("acqdat_asset") do
      remove(:project_id)
    end
  end
end
