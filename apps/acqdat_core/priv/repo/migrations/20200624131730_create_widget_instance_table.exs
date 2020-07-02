defmodule AcqdatCore.Repo.Migrations.CreateWidgetInstanceTable do
  use Ecto.Migration

  def change do
    create table("acqdat_widget_instance") do
      add(:label, :string, null: false)
      add(:uuid, :string, null: false)
      add(:slug, :string, null: false)
      add(:default_values, :map)
      add(:properties, :map)
      add(:visual_settings, :map)
      add(:data_settings, :map)
      add(:series_data, :map)
      add(:widget_settings, :map)
      add(:widget_id, references("acqdat_widgets", on_delete: :delete_all), null: false)
      add(:dashboard_id, references("acqdat_dashboard", on_delete: :delete_all), null: false)

      timestamps(type: :timestamptz)
    end

    create unique_index("acqdat_widget_instance", [:slug])
    create unique_index("acqdat_widget_instance", [:uuid])
    create unique_index("acqdat_widget_instance", [:dashboard_id, :label], name: :unique_widget_name_per_dashboard)
  end
end
