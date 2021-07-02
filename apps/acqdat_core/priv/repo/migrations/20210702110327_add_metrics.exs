defmodule AcqdatCore.Repo.Migrations.AddMetrics do
  use Ecto.Migration

  def change do
    create table("acqdat_metrics") do

      add(:inserted_time, :timestamptz, null: false)

      add(:metrics, references("metrics_meta", on_delete: :delete_all))

      timestamps(type: :timestamptz)
    end
  end
end
