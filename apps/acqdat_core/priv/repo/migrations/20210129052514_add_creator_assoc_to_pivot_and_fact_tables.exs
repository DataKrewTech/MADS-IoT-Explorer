 defmodule AcqdatCore.Repo.Migrations.AddCreatorAssocToPivotAndFactTables do
  use Ecto.Migration

  def change do
  	alter table("acqdat_pivot_tables") do
      add(:creator_id, references(:users))
    end

    alter table("acqdat_fact_tables") do
      add(:creator_id, references(:users))
    end
  end
end
