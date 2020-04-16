defmodule AcqdatCore.Repo.Migrations.AlterUsersTable do
  use Ecto.Migration

  def change do
    alter table("users") do
      add(:role_id, references(:acqdat_roles), null: false)
      add(:is_invited, :boolean, null: false)
    end

  end
end
