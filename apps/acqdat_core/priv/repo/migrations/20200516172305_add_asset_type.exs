defmodule AcqdatCore.Repo.Migrations.AddAssetType do
  use Ecto.Migration

  def change do
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

    create unique_index("acqdat_asset_types", [:name, :org_id])
    create unique_index("acqdat_asset_types", [:slug])
    create unique_index("acqdat_asset_types", [:uuid])
  end
end
