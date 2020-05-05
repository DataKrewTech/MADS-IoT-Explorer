defmodule AcqdatCore.Repo.Migrations.AddIconIdColumnToAppsTable do
  use Ecto.Migration

  def up do
    alter table("acqdat_apps") do
      add(:icon_id, :string)
    end
  end

  def down do
    alter table("acqdat_apps") do
      remove(:icon_id)
    end
  end
end
