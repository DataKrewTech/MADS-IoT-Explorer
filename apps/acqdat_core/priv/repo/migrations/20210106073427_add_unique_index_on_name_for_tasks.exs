defmodule AcqdatCore.Repo.Migrations.AddUniqueIndexOnNameForTasks do
  use Ecto.Migration

  def change do
  	create unique_index("acqdat_tasks", [:name, :user_id, :org_id], name: :unique_task_name_per_user_n_org)
  end
end
