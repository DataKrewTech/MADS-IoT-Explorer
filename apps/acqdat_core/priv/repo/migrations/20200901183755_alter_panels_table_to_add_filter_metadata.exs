defmodule AcqdatCore.Repo.Migrations.AlterPanelsTableToAddFilterMetadata do
  use Ecto.Migration

  def up do
    alter table("acqdat_panel") do
      add(:filter_metadata, :map)
    end
  end

  def down do
    alter table("acqdat_panel") do
      remove(:filter_metadata)
    end
  end
end
