defmodule AcqdatCore.Repo.Migrations.CreateDashboardTable do
  use Ecto.Migration

  def change do
    create table("acqdat_dashboard") do
      add(:name, :string, null: false)
      add(:uuid, :string, null: false)
      add(:slug, :string, null: false)
      add(:settings, :map)
      add(:org_id, references("acqdat_organisation", on_delete: :delete_all), null: false)
      add(:project_id, references("acqdat_projects", on_delete: :delete_all), null: false)

      timestamps(type: :timestamptz)
    end

    create unique_index("acqdat_dashboard", [:slug])
    create unique_index("acqdat_dashboard", [:uuid])
    create unique_index("acqdat_dashboard", [:project_id, :name], name: :unique_dashboard_name_per_project)
  end
end
