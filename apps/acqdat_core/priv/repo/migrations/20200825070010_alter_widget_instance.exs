defmodule AcqdatCore.Repo.Migrations.AlterWidgetInstance do
  use Ecto.Migration

  def up do
    alter table("acqdat_widget_instance") do
      add(:panel_id, references("acqdat_panel", on_delete: :delete_all))
    end
    
    drop_if_exists index("acqdat_widget_instance", [:name], name: :unique_widget_name_per_dashboard)
    create unique_index("acqdat_widget_instance", [:panel_id, :label], where: "panel_id != null", name: :unique_widget_name_per_panel)
  end

  def down do
    drop_if_exists index("acqdat_widget_instance", [:name], name: :unique_widget_name_per_panel)
    create unique_index("acqdat_widget_instance", [:dashboard_id, :label], name: :unique_widget_name_per_dashboard)
    
    alter table("acqdat_widget_instance") do
      remove(:panel_id)
    end
  end
end
