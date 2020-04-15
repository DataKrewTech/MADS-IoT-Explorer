defmodule AcqdatCore.Repo.Migrations.AddTableAssetUser do
  use Ecto.Migration

  def up do
    create table(:asset_user, primary_key: false) do
      add(:asset_id, references(:acqdat_asset, on_delete: :delete_all), primary_key: true)
      add(:user_id, references(:users, on_delete: :delete_all), primary_key: true)
    end

    create(index(:asset_user, [:asset_id]))
    create(index(:asset_user, [:user_id]))

    create(unique_index(:asset_user, [:user_id, :asset_id], name: :user_id_asset_id_unique_index))
  end

  def down do
    drop(index(:asset_user, [:user_id, :asset_id], name: :user_id_asset_id_unique_index))
    drop(index(:asset_user, [:user_id]))
    drop(index(:asset_user, [:asset_id]))
    drop(table(:asset_user))
  end
end
