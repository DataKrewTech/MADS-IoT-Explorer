defmodule AcqdatCore.Repo.Migrations.AcqdatGatewayDataDump do
  use Ecto.Migration

  def change do
     # Create Gateway Data Dump Table which will hold data for the initial period
     create table(:acqdat_gateway_data_dump) do
      add(:inserted_timestamp, :timestamptz, null: false, primary_key: true)

      add(:org_id, references("acqdat_organisation", on_delete: :restrict),
        null: false,
        primary_key: true
      )

      add(:gateway_id, references("acqdat_gateway", on_delete: :restrict),
        null: false,
        primary_key: true
      )

      add(:project_id, references("acqdat_projects", on_delete: :restrict),
        null: false,
        primary_key: true
      )
      add(:data, :map, null: false)
      timestamps(type: :timestamptz, updated_at: false)
    end
  end
end
