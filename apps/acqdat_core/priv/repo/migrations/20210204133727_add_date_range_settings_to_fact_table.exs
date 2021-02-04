defmodule AcqdatCore.Repo.Migrations.AddDateRangeSettingsToFactTable do
  use Ecto.Migration

  def change do
    alter table("acqdat_fact_tables") do
      add(:date_range_settings, :map)
    end
  end
end
