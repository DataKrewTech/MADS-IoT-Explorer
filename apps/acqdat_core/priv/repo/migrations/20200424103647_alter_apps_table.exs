defmodule AcqdatCore.Repo.Migrations.AlterAppsTable do
  use Ecto.Migration

  def up do
  	alter table("acqdat_apps") do
      add(:uuid, :string, null: false)
      add(:category, :string)
      add(:vendor, :string)
      add(:vendor_url, :string)
      add(:app_store_price, :float)
      add(:app_store_rating, :float)
      add(:in_app_purchases, :boolean)
      add(:in_app_purchases_data, :map)
      add(:compatibility, :string)
      add(:activity_rating, :float)
      add(:copyright, :string)
      add(:license, :string)
      add(:tnc, :string)
      add(:documentation, :string)
      add(:privacy_policy, :string)
      add(:current_version, :float)
      add(:first_date_of_release, :timestamptz)
      add(:most_recent_date_of_release, :timestamptz)
      add(:release_history, :map)
    end

    create unique_index("acqdat_apps", [:uuid])
    create unique_index("acqdat_apps", [:name])
  end

  def down do
  	drop unique_index(:acqdat_apps, [:name])
  	drop unique_index(:acqdat_apps, [:uuid])

    alter table("acqdat_apps") do
      remove(:uuid)
      remove(:category)
      remove(:vendor)
      remove(:vendor_url)
      remove(:app_store_price)
      remove(:app_store_rating)
      remove(:in_app_purchases)
      remove(:in_app_purchases_data)
      remove(:compatibility)
      remove(:activity_rating)
      remove(:copyright)
      remove(:license)
      remove(:tnc)
      remove(:documentation)
      remove(:privacy_policy)
      remove(:current_version)
      remove(:first_date_of_release)
      remove(:most_recent_date_of_release)
      remove(:release_history)
    end
  end
end
