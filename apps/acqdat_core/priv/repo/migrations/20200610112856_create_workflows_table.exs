defmodule AcqdatCore.Repo.Migrations.CreateWorkflowsTable do
  use Ecto.Migration

  def change do
    create table("acqdat_workflows") do
      add(:uuid, :string, null: false)
      add(:graph, :map)
      add(:input_data, {:array, :map})
      add(:task_id, references("acqdat_tasks", on_delete: :delete_all), null: false)

      timestamps(type: :timestamptz)
    end

    create unique_index("acqdat_workflows", [:uuid])
  end
end
