defmodule AcqdatCore.Repo.Migrations.CreateVisualizationsTable do
  use Ecto.Migration

  def change do
    create table("acqdat_visualizations") do
      add(:name, :string, null: false)
      add(:uuid, :string, null: false)
      add(:slug, :string, null: false)
      add(:module, VisualizationsModuleSchemaEnum.type(), null: false)
      add(:type, VisualizationsModuleEnum.type(), null: false)
      add(:visual_settings, :map)
      add(:data_settings, :map)

      add(:org_id, references("acqdat_organisation", on_delete: :delete_all), null: false)
      add(:project_id, references("acqdat_projects", on_delete: :delete_all), null: false)
      add(:fact_table_id, references("acqdat_fact_tables", on_delete: :delete_all), null: false)
      add(:creator_id, references("users"), null: false)

      timestamps(type: :timestamptz)
    end

    create unique_index("acqdat_visualizations", [:slug])
    create unique_index("acqdat_visualizations", [:uuid])
    create unique_index("acqdat_visualizations", [:fact_table_id, :name], name: :unique_visualization_name_per_fact_table)
  end
end

