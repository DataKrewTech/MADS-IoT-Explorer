defmodule AcqdatCore.Repo.Migrations.AddAssetType do
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
      add(:project_id, references("acqdat_projects", on_delete: :restrict), null: false)
      add(:org_id, references("acqdat_organisation", on_delete: :delete_all), null: false)


      timestamps(type: :timestamptz)
    end

    alter table("acqdat_asset") do
      add(:asset_type_id, references("acqdat_asset_types", on_delete: :delete_all))
      remove(:metadata)
      remove(:asset_category_id)
      add(:metadata, {:array, :map})
    end

    create unique_index("acqdat_asset_types", [:name, :org_id, :project_id])
    create unique_index("acqdat_asset_types", [:slug])
    create unique_index("acqdat_asset_types", [:uuid])
    create index("acqdat_asset", [:asset_type_id])
  end

  def down do

    drop unique_index("acqdat_asset_types", [:name, :org_id, :project_id])
    drop unique_index("acqdat_asset_types", [:slug])
    drop unique_index("acqdat_asset_types", [:uuid])
    drop index("acqdat_asset", [:asset_type_id])

    alter table("acqdat_asset") do
      remove(:asset_type_id)
      add(:metadata, :map)
      add(:asset_category_id, references("acqdat_asset_categories", on_delete: :restrict))
      remove(:metadata)
    end

    drop table("acqdat_asset_types")

  end
end
