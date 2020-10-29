defmodule AcqdatCore.Repo.Migrations.AddGraphJsonColumnToTasksTable do
  use Ecto.Migration

  def up do
    alter table("acqdat_tasks") do
      add(:graph_json, :map)
    end
  end

  def down do
    alter table("acqdat_tasks") do
      remove(:graph_json)
    end
  end
end
