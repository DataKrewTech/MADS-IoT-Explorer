defmodule AcqdatCore.Repo.Migrations.ProjectUsers do
  use Ecto.Migration

  def change do
    create table("acqdat_project_users") do
      add(:project_id, references("acqdat_projects", on_delete: :restrict), null: false)
      add(:user_id, references(:users, on_delete: :restrict), null: false)
    end

    create unique_index("acqdat_project_users", [:user_id, :project_id])
  end
end
