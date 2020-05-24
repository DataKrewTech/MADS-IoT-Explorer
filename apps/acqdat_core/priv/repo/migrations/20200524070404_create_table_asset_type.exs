defmodule AcqdatCore.Repo.Migrations.CreateTableAssetType do
  use Ecto.Migration

  def up do
    create table("acqdat_asset_types") do
      add(:name, :string, null: false)
      add(:description, :string)
      add(:metadata, {:array, :map})
      add(:uuid, :string, null: false)
      add(:slug, :string, null: false)
      add(:parameters, {:array, :map})
      add(:sensor_type_present, :boolean, default: false)
      add(:sensor_type_uuid, :string)
      add(:org_id, references("acqdat_organisation", on_delete: :delete_all), null: false)


      timestamps(type: :timestamptz)
    end

    alter table("acqdat_asset") do
      add(:asset_type_id, references("acqdat_asset_types", on_delete: :delete_all))
      #remove(:metadata)
      add(:metadata, {:array, :map})
    end

    create unique_index("acqdat_asset_types", [:name, :org_id])
    create unique_index("acqdat_asset_types", [:slug])
    create unique_index("acqdat_asset_types", [:uuid])
    create index("acqdat_asset", [:asset_type_id])
  end

  def down do
    drop unique_index("acqdat_asset_types", [:name, :org_id])
    drop unique_index("acqdat_asset_types", [:slug])
    drop unique_index("acqdat_asset_types", [:uuid])
    drop index("acqdat_asset", [:asset_type_id])

    alter table("acqdat_asset") do
      remove(:asset_type_id)
      remove(:metadata)
    end

    drop(table(:acqdat_asset_types))
  end
end
