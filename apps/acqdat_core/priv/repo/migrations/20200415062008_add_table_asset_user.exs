defmodule AcqdatCore.Repo.Migrations.AddTableAssetUser do
  use Ecto.Migration

  def up do
    create table(:asset_user) do
      add(:asset_id, references(:acqdat_asset, on_delete: :delete_all))
      add(:user_id, references(:users, on_delete: :delete_all))
    end

    create(index(:asset_user, [:asset_id]))
    create(index(:asset_user, [:user_id]))

    create(unique_index(:asset_user, [:user_id, :asset_id], name: :user_id_asset_id_unique_index))
  end

  def down do
    drop(index(:asset_user, [:user_id, :asset_id], name: :user_id_asset_id_unique_index))
    drop constraint(:asset_user, "asset_user_asset_id_fkey")
    drop constraint(:asset_user, "asset_user_user_id_fkey")
    drop(index(:asset_user, [:user_id]))
    drop(index(:asset_user, [:asset_id]))
    drop(table(:asset_user))
  end
end
