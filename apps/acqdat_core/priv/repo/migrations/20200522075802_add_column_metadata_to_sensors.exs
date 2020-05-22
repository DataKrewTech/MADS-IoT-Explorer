defmodule AcqdatCore.Repo.Migrations.AddColumnMetadataToSensors do
  use Ecto.Migration

  def change do
    alter table("acqdat_sensors") do
      add(:metadata, {:array, :map})
    end
  end
end
