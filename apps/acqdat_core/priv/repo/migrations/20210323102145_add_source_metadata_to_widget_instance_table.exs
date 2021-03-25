defmodule AcqdatCore.Repo.Migrations.AddSourceMetadataToWidgetInstanceTable do
  use Ecto.Migration

  def change do
    alter table("acqdat_widget_instance") do
      add(:source_app, :string)
      add(:source_metadata, :map)
    end
  end
end
