defmodule AcqdatCore.Repo.Migrations.RemoveProjectIdFromDashboard do
  use Ecto.Migration

  def up do
    alter table("acqdat_dashboard") do
      remove(:project_id)
    end
    
    create unique_index("acqdat_dashboard", [:org_id, :name], name: :unique_dashboard_name_per_org)
  end

  def down do
    alter table("acqdat_dashboard") do
      add(:project_id, references("acqdat_projects", on_delete: :delete_all), null: false)
    end
    
    drop index("acqdat_dashboard", [:org_id, :name], name: :unique_dashboard_name_per_org)
    create unique_index("acqdat_dashboard", [:project_id, :name], name: :unique_project_name_per_org)
  end
end
