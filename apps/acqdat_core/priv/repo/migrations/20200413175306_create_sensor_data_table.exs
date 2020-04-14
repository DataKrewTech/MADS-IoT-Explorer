defmodule AcqdatCore.Repo.Migrations.CreateSensorDataTable do
  use Ecto.Migration

  def up do
    # Create SensorsData Table to store timeseries related data
    create table(:acqdat_sensors_data, primary_key: false) do
      add(:inserted_timestamp, :timestamptz, null: false, primary_key: true)

      add(:org_id, references("acqdat_organisation", on_delete: :delete_all),
        null: false,
        primary_key: true
      )

      add(:sensor_id, references("acqdat_sensors", on_delete: :delete_all),
        null: false,
        primary_key: true
      )

      add(:parameters, {:array, :map})
      timestamps(type: :timestamptz, updated_at: false)
    end

    create(unique_index(:acqdat_sensors_data, [:inserted_timestamp, :org_id, :sensor_id]))
    flush()
    # Convert above created SensorsData Table to HyperTable to incorporate timeseries data
    # TODO: Need to think, if we can use time_partitioning_func for the chunk partioning, on the basis of (inserted_timestamp + org_id + sensor_id)
    execute("SELECT create_hypertable('acqdat_sensors_data', 'inserted_timestamp')")
  end

  def down do
    drop(index(:acqdat_sensors_data, [:inserted_timestamp, :org_id, :sensor_id]))
    drop(table(:acqdat_sensors_data))
  end
end
