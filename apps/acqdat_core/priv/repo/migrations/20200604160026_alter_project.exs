defmodule AcqdatCore.Repo.Migrations.AlterProject do
  use Ecto.Migration

  def up do
    alter table("acqdat_projects") do
      remove(:metadata)
      add(:metadata, {:array, :map})
    end
  end

  def down do
    alter table("acqdat_projects") do
      remove(:metadata)
      add(:metadata, :map)
    end
  end
end
