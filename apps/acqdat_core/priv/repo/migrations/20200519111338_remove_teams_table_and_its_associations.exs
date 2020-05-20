defmodule AcqdatCore.Repo.Migrations.RemoveTeamsTableAndItsAssociations do
  use Ecto.Migration

  def change do
  	drop(index(:teams_apps, [:team_id, :app_id], name: :team_id_app_id_unique_index))
    drop(index(:teams_apps, [:team_id]))
    drop(index(:teams_apps, [:app_id]))
    drop(table(:teams_apps))

    drop(index(:teams_assets, [:asset_id, :team_id], name: :asset_id_team_id_unique_index))
    drop(index(:teams_assets, [:asset_id]))
    drop(index(:teams_assets, [:team_id]))
    drop(table(:teams_assets))

    drop(index(:users_teams, [:user_id, :team_id], name: :user_id_team_id_unique_index))
    drop(index(:users_teams, [:user_id]))
    drop(index(:users_teams, [:team_id]))
    drop(table(:users_teams))

    drop(unique_index(:acqdat_teams, [:name]))
    drop(table(:acqdat_teams))
  end
end
