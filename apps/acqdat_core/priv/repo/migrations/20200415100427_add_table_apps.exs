defmodule AcqdatCore.Repo.Migrations.AddTableApps do
  use Ecto.Migration

  def change do
    create table("acqdat_apps") do
      add(:name, :string, null: false)
      add(:description, :string)
      add(:avatar, :string)

      timestamps(type: :timestamptz)
    end
  end
end
