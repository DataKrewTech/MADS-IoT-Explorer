defmodule AcqdatCore.Repo.Migrations.CreateTableTeams do
  use Ecto.Migration

  def up do
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
  end

  def down do
    drop(unique_index(:acqdat_teams, [:name]))
    drop(table(:acqdat_teams))
  end
end
