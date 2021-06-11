defmodule AcqdatCore.Repo.Migrations.AddMetadataColumnToUserCredentialsTable do
  use Ecto.Migration

  def change do
    alter table("acqdat_user_credentials") do
      add(:metadata, :map)
    end
  end
end
