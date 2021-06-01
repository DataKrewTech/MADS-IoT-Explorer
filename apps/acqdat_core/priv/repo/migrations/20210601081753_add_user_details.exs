defmodule AcqdatCore.Repo.Migrations.AddUserDetails do
  use Ecto.Migration

  def change do
    alter table("users") do
      add(:user_credentials_id, references("acqdat_user_credentials"))
    end

    create(index(:users, [:user_credentials_id]))
  end
end
