defmodule AcqdatCore.Repo.Migrations.CreateTableTeamsApps do
  use Ecto.Migration

  def up do
    create table(:teams_apps, primary_key: false) do
      add(:app_id, references(:acqdat_apps, on_delete: :delete_all), primary_key: true)
      add(:team_id, references(:acqdat_teams, on_delete: :delete_all), primary_key: true)
    end

    create(index(:teams_apps, [:app_id]))
    create(index(:teams_apps, [:team_id]))

    create(unique_index(:teams_apps, [:team_id, :app_id], name: :team_id_app_id_unique_index))
  end

  def down do
    drop(index(:teams_apps, [:team_id, :app_id], name: :team_id_app_id_unique_index))
    drop(index(:teams_apps, [:team_id]))
    drop(index(:teams_apps, [:app_id]))
    drop(table(:teams_apps))
  end
end
