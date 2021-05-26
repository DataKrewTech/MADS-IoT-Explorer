defmodule AcqdatCore.Repo.Migrations.CreateGatewayDataTable do
  use Ecto.Migration

  def up do
    # Create GatewayData Table to store timeseries related data of gateway
    create table(:acqdat_gateway_data, primary_key: false) do
      add(:inserted_timestamp, :timestamptz, null: false, primary_key: true)
      add(:org_id, :integer, null: false, primary_key: true)
      add(:gateway_id, :integer, null: false, primary_key: true)
      add(:project_id, :integer, null: false, primary_key: true)

      add(:parameters, :map)
      timestamps(type: :timestamptz, updated_at: false)
    end

    create(unique_index(:acqdat_gateway_data,
      [:inserted_timestamp, :org_id, :gateway_id, :project_id]))
    create(index(:acqdat_gateway_data, [:gateway_id, :project_id]))
    flush()
    # Convert above created GatewayData Table to HyperTable to incorporate timeseries data
    # TODO: Need to think, if we can use time_partitioning_func for the chunk partioning, on the basis of (inserted_timestamp + org_id + gateway_id)
    # execute("SELECT create_hypertable('acqdat_gateway_data', 'inserted_timestamp')")
  end

  def down do
    drop(index(:acqdat_gateway_data, [:inserted_timestamp, :org_id, :gateway_id, :project_id]))
    drop(index(:acqdat_gateway_data, [:gateway_id, :project_id]))
    drop(table(:acqdat_gateway_data))
  end
end
