defmodule AcqdatCore.Repo.Migrations.AlterCommandWidgetToIncludePanel do
  use Ecto.Migration

  def up do
    alter table("acqdat_command_widgets") do
      add(:panel_id, references("acqdat_panel", on_delete: :delete_all))
      remove(:dashboard_id)
    end
  end

  def down do
    alter table("acqdat_command_widgets") do
      remove(:panel_id)
      add(:dashboard_id, references("acqdat_dashboard", on_delete: :delete_all))
    end
  end
end
