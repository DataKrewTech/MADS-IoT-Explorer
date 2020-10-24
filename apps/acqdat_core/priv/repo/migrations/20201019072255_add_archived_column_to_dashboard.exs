defmodule AcqdatCore.Repo.Migrations.AddArchivedColumnToDashboard do
  use Ecto.Migration

  def up do
    alter table("acqdat_dashboard") do
      add(:archived, :boolean, default: false)
    end
    
    create(index("acqdat_dashboard", [:archived]))
  end

  def down do
    drop(index("acqdat_dashboard", [:archived]))
    
    alter table("acqdat_dashboard") do
      remove(:archived)
    end
  end
end
