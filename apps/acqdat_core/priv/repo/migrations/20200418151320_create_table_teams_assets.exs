defmodule AcqdatCore.Repo.Migrations.CreateTableTeamsAssets do
  use Ecto.Migration

  def up do
    create table(:teams_assets, primary_key: false) do
      add(:team_id, references(:acqdat_teams, on_delete: :delete_all), primary_key: true)
      add(:asset_id, references(:acqdat_asset, on_delete: :delete_all), primary_key: true)
    end

    create(index(:teams_assets, [:team_id]))
    create(index(:teams_assets, [:asset_id]))

    create(
      unique_index(:teams_assets, [:asset_id, :team_id], name: :asset_id_team_id_unique_index)
    )
  end

  def down do
    drop(index(:teams_assets, [:asset_id, :team_id], name: :asset_id_team_id_unique_index))
    drop(index(:teams_assets, [:asset_id]))
    drop(index(:teams_assets, [:team_id]))
    drop(table(:teams_assets))
  end
end
