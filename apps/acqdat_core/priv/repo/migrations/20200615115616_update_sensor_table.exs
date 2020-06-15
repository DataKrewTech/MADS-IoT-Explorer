defmodule AcqdatCore.Repo.Migrations.UpdateSensorTable do
  use Ecto.Migration

  def change do
    alter table("acqdat_sensors") do
      add(:description, :string)
    end
  end
end
