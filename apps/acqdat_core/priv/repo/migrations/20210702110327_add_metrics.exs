defmodule AcqdatCore.Repo.Migrations.AddMetrics do
  use Ecto.Migration

  def change do
    create table("acqdat_metrics") do

      add(:inserted_time, :timestamptz, null: false)
      add(:metrics, :map)
      timestamps(type: :timestamptz)
    end
  end
end
