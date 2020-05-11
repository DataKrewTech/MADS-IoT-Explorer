defmodule AcqdatCore.Repo.Migrations.AlterAssetTable do
  use Ecto.Migration

  def change do
    alter table("acqdat_asset_categories") do
      add(:creator_id, references(:users))
      add(:owner_id, references(:users))
    end
  end
end
