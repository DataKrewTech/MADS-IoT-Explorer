defmodule AcqdatCore.Repo.Migrations.AlterUsers do
  use Ecto.Migration

  def change do
    alter table("users") do
      add(:is_deleted, :boolean, default: false)
    end
  end
end
