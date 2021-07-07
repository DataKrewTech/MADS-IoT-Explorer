defmodule AcqdatCore.Repo.Migrations.AddMetrics do
  use Ecto.Migration

  def change do
    create table("acqdat_metrics") do

      add(:inserted_time, :timestamptz, null: false)
      add(:org_id, :integer, null: false)
      add(:metrics, :map)
      timestamps(type: :timestamptz)

    end
    create index("acqdat_metrics", [:org_id, :inserted_time])
  end
end
