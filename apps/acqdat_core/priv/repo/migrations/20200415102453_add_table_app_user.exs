defmodule AcqdatCore.Repo.Migrations.AddTableAppUser do
  use Ecto.Migration

  def up do
    create table(:app_user, primary_key: false) do
      add(:app_id, references(:acqdat_apps, on_delete: :delete_all), primary_key: true)
      add(:user_id, references(:users, on_delete: :delete_all), primary_key: true)
    end

    create(index(:app_user, [:app_id]))
    create(index(:app_user, [:user_id]))

    create(unique_index(:app_user, [:user_id, :app_id], name: :user_id_app_id_unique_index))
  end

  def down do
    drop(index(:app_user, [:user_id, :app_id], name: :user_id_app_id_unique_index))
    drop(index(:app_user, [:user_id]))
    drop(index(:app_user, [:app_id]))
    drop(table(:app_user))
  end
end
