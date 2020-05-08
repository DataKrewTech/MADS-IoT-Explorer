defmodule AcqdatCore.Repo.Migrations.AddIconIdColumnToAppsTable do
  use Ecto.Migration

  def up do
    alter table("acqdat_apps") do
      add(:icon_id, :string)
      add(:key, :string, null: false)
    end
    create unique_index(:acqdat_apps, [:key])
  end

  def down do
    drop unique_index(:acqdat_apps, [:key])

    alter table("acqdat_apps") do
      remove(:icon_id)
      remove(:key)
    end
  end
end
