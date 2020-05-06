defmodule AcqdatCore.Repo.Migrations.AlterSensor do
  use Ecto.Migration

  def change do
    alter table("acqdat_sensors") do
      remove(:parameters, {:array, :map})
      add(:sensor_type_id, references("acqdat_sensor_types", on_delete: :delete_all))
    end
  end
end
