defmodule AcqdatCore.Repo.Migrations.CreatePivotTables do
  use Ecto.Migration

  def change do
    create table("acqdat_pivot_tables") do
      add(:name, :string, null: false)
      add(:uuid, :string, null: false)
      add(:slug, :string, null: false)
      add(:filters, {:array, :map}, default: [])
      add(:columns, {:array, :map}, default: [])
      add(:rows, {:array, :map}, default: [])
      add(:values, {:array, :map}, default: [])

      add(:org_id, references("acqdat_organisation", on_delete: :delete_all), null: false)
      add(:project_id, references("acqdat_projects", on_delete: :delete_all), null: false)
      add(:fact_table_id, references("acqdat_fact_tables", on_delete: :delete_all), null: false)

      timestamps(type: :timestamptz)
    end

    create unique_index("acqdat_pivot_tables", [:slug])
    create unique_index("acqdat_pivot_tables", [:uuid])
    create unique_index("acqdat_pivot_tables", [:fact_table_id, :name], name: :unique_pivot_table_name_per_fact_table)
  end
end
