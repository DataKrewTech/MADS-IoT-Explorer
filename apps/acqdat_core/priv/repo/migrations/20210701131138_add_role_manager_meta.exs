defmodule AcqdatCore.Repo.Migrations.AddRoleManagerMeta do
  use Ecto.Migration

  def change do
    create table("role_manager_meta") do
      add(:users, :map)
    end
  end
end
