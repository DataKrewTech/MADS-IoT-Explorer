defmodule AcqdatCore.Repo.Migrations.AddArchivedColumnToDashboard do
  use Ecto.Migration

  def up do
    alter table("acqdat_dashboard") do
      add(:archived, :boolean, default: false)
    end
  end

  def down do
    alter table("acqdat_dashboard") do
      remove(:archived)
    end
  end
end
