defmodule AcqdatCore.Repo.Migrations.AddCommandWidgets do
  use Ecto.Migration

  def change do
    create table("acqdat_command_widgets") do
      add(:label, :string, null: false)
      add(:properties, :map)
      add(:uuid, :string)
      add(:module, CommandWidgetSchemaEnum.type, null: false)
      add(:visual_settings, :map)
      add(:data_settings, :map)
      add(:command_widget_type, :string, null: false)

      # associations
      add(:gateway_id, references("acqdat_gateway", on_delete: :delete_all), null: false)
      add(:dashboard_id, references("acqdat_dashboard", on_delete: :delete_all), null: false)

      timestamps(type: :timestamptz)
    end
  end
end
