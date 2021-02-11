defmodule AcqdatCore.Repo.Migrations.RenamePivotTablesToVisualizations do
  use Ecto.Migration

  def up do
  	drop index(:acqdat_pivot_tables, [:slug])
  	drop index(:acqdat_pivot_tables, [:uuid])
  	drop index(:acqdat_pivot_tables, [:fact_table_id, :name], name: :unique_pivot_table_name_per_fact_table)
    drop constraint(:acqdat_pivot_tables, "acqdat_pivot_tables_creator_id_fkey")
    drop constraint(:acqdat_pivot_tables, "acqdat_pivot_tables_fact_table_id_fkey")
    drop constraint(:acqdat_pivot_tables, "acqdat_pivot_tables_org_id_fkey")
    drop constraint(:acqdat_pivot_tables, "acqdat_pivot_tables_project_id_fkey")
    drop constraint(:acqdat_pivot_tables, "acqdat_pivot_tables_pkey")

    rename table(:acqdat_pivot_tables), to: table(:acqdat_visualizations)

    alter table(:acqdat_visualizations) do
      modify :id, :bigint, primary_key: true
      modify(:org_id, references("acqdat_organisation", on_delete: :delete_all), null: false)
      modify(:project_id, references("acqdat_projects", on_delete: :delete_all), null: false)
      modify(:fact_table_id, references("acqdat_fact_tables", on_delete: :delete_all), null: false)
      modify(:creator_id, references("users"), null: false)
    end

    execute "ALTER SEQUENCE acqdat_pivot_tables_id_seq RENAME TO acqdat_visualizations_id_seq;"

    create unique_index("acqdat_visualizations", [:slug])
    create unique_index("acqdat_visualizations", [:uuid])
    create unique_index("acqdat_visualizations", [:fact_table_id, :name], name: :unique_visualization_name_per_fact_table)
  end

  def down do
    drop index(:acqdat_visualizations, [:slug])
  	drop index(:acqdat_visualizations, [:uuid])
  	drop index(:acqdat_visualizations, [:fact_table_id, :name], name: :unique_visualization_name_per_fact_table)
    drop constraint(:acqdat_visualizations, "acqdat_visualizations_creator_id_fkey")
    drop constraint(:acqdat_visualizations, "acqdat_visualizations_fact_table_id_fkey")
    drop constraint(:acqdat_visualizations, "acqdat_visualizations_org_id_fkey")
    drop constraint(:acqdat_visualizations, "acqdat_visualizations_project_id_fkey")
    drop constraint(:acqdat_visualizations, "acqdat_visualizations_pkey")

    rename table(:acqdat_visualizations), to: table(:acqdat_pivot_tables)

    alter table(:acqdat_pivot_tables) do
      modify :id, :bigint, primary_key: true
      modify(:org_id, references("acqdat_organisation", on_delete: :delete_all), null: false)
      modify(:project_id, references("acqdat_projects", on_delete: :delete_all), null: false)
      modify(:fact_table_id, references("acqdat_fact_tables", on_delete: :delete_all), null: false)
      modify(:creator_id, references("users"), null: false)
    end

    create unique_index("acqdat_pivot_tables", [:slug])
    create unique_index("acqdat_pivot_tables", [:uuid])
    create unique_index("acqdat_pivot_tables", [:fact_table_id, :name], name: :unique_pivot_table_name_per_fact_table)

    execute "ALTER SEQUENCE acqdat_visualizations_id_seq RENAME TO acqdat_pivot_tables_id_seq;"
  end
end
