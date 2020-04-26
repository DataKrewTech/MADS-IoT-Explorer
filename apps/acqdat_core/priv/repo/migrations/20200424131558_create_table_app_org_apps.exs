defmodule AcqdatCore.Repo.Migrations.CreateTableAppOrgApps do
  use Ecto.Migration

  def up do
  	create table(:org_apps, primary_key: false) do
      add(:app_id, references(:acqdat_apps, on_delete: :delete_all), primary_key: true)
      add(:org_id, references(:acqdat_organisation, on_delete: :delete_all), primary_key: true)
    end

    create(index(:org_apps, [:app_id]))
    create(index(:org_apps, [:org_id]))

    create(unique_index(:org_apps, [:app_id, :org_id], name: :org_apps_unique_index))
  end

  def down do 
  	drop(index(:org_apps, [:app_id, :org_id], name: :org_apps_unique_index))
    drop(index(:org_apps, [:org_id]))
    drop(index(:org_apps, [:app_id]))
    drop(table(:org_apps)) 	
  end
end
