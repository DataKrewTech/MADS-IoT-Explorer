defmodule AcqdatCore.Repo.Migrations.ChangeProjectVersionToFloatFromInteger do
  use Ecto.Migration

  def up do
    alter table("acqdat_projects") do
      modify :version, :float, default: 1.0
    end
  end

  def down do
    alter table("acqdat_projects") do
      modify :version, :integer, default: 1
    end
  end
end
