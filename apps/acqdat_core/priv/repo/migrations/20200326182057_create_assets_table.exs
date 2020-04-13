defmodule AcqdatCore.Repo.Migrations.CreateAssetsTable do
  use Ecto.Migration

  def change do
    create table("acqdat_asset_categories") do
      add(:name, :string, null: false)
      add(:metadata, :map)
      add(:description, :string)
      add(:uuid, :string, null: false)
      add(:organisation_id, references("acqdat_organisation", on_delete: :delete_all), null: false)

      timestamps(type: :timestamptz)
    end

    create table("acqdat_asset") do
      add(:uuid, :string, null: false)
      add(:slug, :string, null: false)
      add(:org_id, references("acqdat_organisation", on_delete: :delete_all), null: false)
      add(:parent_id, :integer)
      add(:lft, :integer)
      add(:rgt, :integer)
      add(:properties, {:array, :string}, default: [])
      add(:metadata, :map)
      add(:name, :string)
      add(:description, :text)
      add(:mapped_parameters, {:array, :map}, default: [])
      add(:image_url, :string)

      timestamps(type: :timestamptz)
    end

    create unique_index("acqdat_asset_categories", [:name, :organisation_id])
    create unique_index("acqdat_asset", [:name, :parent_id, :org_id])
    create unique_index("acqdat_asset", [:slug])
    create unique_index("acqdat_asset", [:uuid])

  end
end
