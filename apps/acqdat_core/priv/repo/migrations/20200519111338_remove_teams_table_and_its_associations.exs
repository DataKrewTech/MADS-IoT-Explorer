defmodule AcqdatCore.Repo.Migrations.RemoveTeamsTableAndItsAssociations do
  use Ecto.Migration
  def up do
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
  def down do
    create table(:acqdat_teams) do
      add(:name, :string, null: false)
      add(:description, :string)
      add(:team_lead_id, references(:users))
      add(:creator_id, references(:users))
      add(:org_id, references("acqdat_organisation", on_delete: :delete_all), null: false)
      add(:enable_tracking, :boolean, default: false)
      timestamps(type: :timestamptz)
    end
    create(unique_index(:acqdat_teams, [:name]))
    flush()
    create table(:users_teams) do
      add(:team_id, references(:acqdat_teams, on_delete: :delete_all))
      add(:user_id, references(:users, on_delete: :delete_all))
    end
    create(index(:users_teams, [:team_id]))
    create(index(:users_teams, [:user_id]))
    create(unique_index(:users_teams, [:user_id, :team_id], name: :user_id_team_id_unique_index))
    flush()
    create table(:teams_assets) do
      add(:team_id, references(:acqdat_teams, on_delete: :delete_all))
      add(:asset_id, references(:acqdat_asset, on_delete: :delete_all))
    end
    create(index(:teams_assets, [:team_id]))
    create(index(:teams_assets, [:asset_id]))
    create(
      unique_index(:teams_assets, [:asset_id, :team_id], name: :asset_id_team_id_unique_index)
    )
    flush()
    create table(:teams_apps) do
      add(:app_id, references(:acqdat_apps, on_delete: :delete_all))
      add(:team_id, references(:acqdat_teams, on_delete: :delete_all))
    end
    create(index(:teams_apps, [:app_id]))
    create(index(:teams_apps, [:team_id]))
    create(unique_index(:teams_apps, [:team_id, :app_id], name: :team_id_app_id_unique_index))
  end
end
