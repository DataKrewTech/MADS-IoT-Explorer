defmodule AcqdatCore.Repo.Migrations.CreateFactTable do
  use Ecto.Migration

  def change do
    create table("acqdat_fact_tables") do
      add(:name, :string, null: false)
      add(:uuid, :string, null: false)
      add(:slug, :string, null: false)
      add(:from_date, :timestamptz, null: false)
      add(:to_date, :timestamptz, null: false)
      add(:group_interval, :integer)
      add(:group_interval_type, :string)
      add(:columns_metadata, :map)

      add(:org_id, references("acqdat_organisation", on_delete: :delete_all), null: false)
      add(:project_id, references("acqdat_projects", on_delete: :delete_all), null: false)

      timestamps(type: :timestamptz)
    end

    create unique_index("acqdat_fact_tables", [:slug])
    create unique_index("acqdat_fact_tables", [:uuid])
    create unique_index("acqdat_fact_tables", [:project_id, :name], name: :unique_fact_table_name_per_project)
  end
end
