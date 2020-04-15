defmodule AcqdatCore.Repo.Migrations.AcqdatRoles do
  use Ecto.Migration

  def change do
    create table("acqdat_roles") do
      add(:name, :string, null: false)
      add(:description, :text)
      timestamps(type: :timestamptz)
    end

    create unique_index("acqdat_roles", [:name])
  end
end
