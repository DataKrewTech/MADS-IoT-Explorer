defmodule AcqdatCore.Repo.Migrations.AddOrgUrlToOrganisationsTable do
  use Ecto.Migration

  def change do
    alter table("acqdat_organisation") do
      add(:url, :string)
    end

    create unique_index("acqdat_organisation", [:url])
    drop unique_index("acqdat_organisation", [:name])
  end
end
