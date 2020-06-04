defmodule AcqdatCore.Repo.Migrations.ProjectLeads do
  use Ecto.Migration

  def change do
    create table("acqdat_project_leads") do
      add(:project_id, references("acqdat_projects", on_delete: :delete_all), null: false)
      add(:user_id, references(:users, on_delete: :delete_all), null: false)
    end

    create unique_index("acqdat_project_leads", [:user_id, :project_id])
  end
end
