defmodule AcqdatCore.Repo.Migrations.AlterSensorType do
  use Ecto.Migration

  def change do
    alter table("acqdat_sensor_types") do
      add(:generated_by, GeneratedBy.type(), default: 0)
    end
  end
end
