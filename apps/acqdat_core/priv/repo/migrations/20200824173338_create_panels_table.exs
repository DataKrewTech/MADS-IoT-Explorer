defmodule AcqdatCore.Repo.Migrations.CreatePanelsTable do
  use Ecto.Migration

  def change do
  	create table("acqdat_panel") do
      add(:name, :string, null: false)
      add(:description, :string)
      add(:uuid, :string, null: false)
      add(:slug, :string, null: false)
      add(:settings, :map)
      add(:widget_layouts, :map)
      add(:org_id, references("acqdat_organisation", on_delete: :delete_all), null: false)
      add(:dashboard_id, references("acqdat_dashboard", on_delete: :delete_all), null: false)

      timestamps(type: :timestamptz)
    end

    create unique_index("acqdat_panel", [:slug])
    create unique_index("acqdat_panel", [:uuid])
    create unique_index("acqdat_panel", [:dashboard_id, :name], name: :unique_panel_name_per_dashboard)
  end
end
