defmodule AcqdatCore.Repo.Migrations.AddColumnHeaderMetadataToFactTables do
  use Ecto.Migration

  def change do
  	alter table("acqdat_fact_tables") do
      add(:headers_metadata, :map)
    end
  end
end
