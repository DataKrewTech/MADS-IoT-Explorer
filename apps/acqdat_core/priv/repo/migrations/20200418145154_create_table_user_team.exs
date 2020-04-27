defmodule AcqdatCore.Repo.Migrations.CreateTableUserTeam do
  use Ecto.Migration

  def up do
    create table(:users_teams) do
      add(:team_id, references(:acqdat_teams, on_delete: :delete_all))
      add(:user_id, references(:users, on_delete: :delete_all))
    end

    create(index(:users_teams, [:team_id]))
    create(index(:users_teams, [:user_id]))

    create(unique_index(:users_teams, [:user_id, :team_id], name: :user_id_team_id_unique_index))
  end

  def down do
    drop(index(:users_teams, [:user_id, :team_id], name: :user_id_team_id_unique_index))
    drop(index(:users_teams, [:user_id]))
    drop(index(:users_teams, [:team_id]))
    drop(table(:users_teams))
  end
end
