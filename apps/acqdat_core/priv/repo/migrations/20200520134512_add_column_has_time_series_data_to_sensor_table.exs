defmodule AcqdatCore.Repo.Migrations.AddColumnHasTimeSeriesDataToSensorTable do
  use Ecto.Migration

  def change do
    alter table("acqdat_sensors") do
      add :has_timesrs_data, :boolean, default: false
    end
  end
end
