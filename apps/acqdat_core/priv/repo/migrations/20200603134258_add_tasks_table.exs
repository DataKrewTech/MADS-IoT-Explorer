defmodule AcqdatCore.Repo.Migrations.AddTasksTable do
  use Ecto.Migration

  def change do
    create table("acqdat_tasks") do
      add(:name, :string, null: false)
      add(:description, :string)
      add(:type, :string, default: "one_time")
      add(:uuid, :string, null: false)
      add(:slug, :string, null: false)
      add(:user_id, references("users", on_delete: :restrict), null: false)
      add(:org_id, references("acqdat_organisation", on_delete: :delete_all), null: false)

      timestamps(type: :timestamptz)
    end

    create unique_index("acqdat_tasks", [:slug])
    create unique_index("acqdat_tasks", [:uuid])
  end
end
