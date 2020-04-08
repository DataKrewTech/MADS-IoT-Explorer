defmodule AcqdatCore.Repo.Migrations.CreateUserSettings do
  use Ecto.Migration

  def change do
    create table(:user_settings) do
      add(:visual_settings, :map)
      add(:data_settings, :map)
      add(:user_id, references(:users, on_delete: :delete_all))

      timestamps(type: :timestamptz)
    end

    create(index(:user_settings, [:user_id]))
  end
end
