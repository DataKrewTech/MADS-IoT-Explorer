defmodule AcqdatCore.Repo.Migrations.ChangeProjectVersionToFloatFromInteger do
  use Ecto.Migration

  def up do
    alter table("acqdat_projects") do
      modify :version, :decimal, default: 1.0, precision: 2, scale: 1
    end
  end

  def down do
    alter table("acqdat_projects") do
      modify :version, :integer, default: 1
    end
  end
end
