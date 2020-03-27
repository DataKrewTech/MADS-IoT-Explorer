defmodule AcqdatCore.Repo.Migrations.CreateOrganisationTable do
  use Ecto.Migration

  def change do
    create table("acqdat_organisation") do
      add(:uuid, :string, null: false)
      add(:name, :string, null: false)
      add(:metadata, :map)
      add(:description, :text)

      timestamps(type: :timestamptz)
    end

    create unique_index("acqdat_organisation", [:name])
    create unique_index("acqdat_organisation", [:uuid])
  end
end
