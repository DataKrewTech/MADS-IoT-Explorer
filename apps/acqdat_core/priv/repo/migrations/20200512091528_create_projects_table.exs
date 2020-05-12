defmodule AcqdatCore.Repo.Migrations.CreateProjectsTable do
  use Ecto.Migration

  def change do
    create table("acqdat_projects") do
      add(:name, :string, null: false)
      add(:uuid, :string, null: false)
      add(:slug, :string, null: false)
      add(:metadata, :map)
      add(:description, :string)
      add(:avatar, :string)
      add(:archived, :boolean, default: false)
      add(:version, :integer, default: 1)
      add(:start_date, :timestamptz)
      add(:location, :map)

      #associations
      add(:org_id, references("acqdat_organisation", on_delete: :delete_all), null: false)
      add(:creator_id, references(:users))

      timestamps(type: :timestamptz)
    end

    create unique_index("acqdat_projects", [:name, :org_id], name: :unique_project_per_org)
    create unique_index("acqdat_projects", [:uuid])
    create unique_index("acqdat_projects", [:slug])
  end
end
