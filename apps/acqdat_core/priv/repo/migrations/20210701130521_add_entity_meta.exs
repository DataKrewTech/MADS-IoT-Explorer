defmodule AcqdatCore.Repo.Migrations.AddEntityMeta do
  use Ecto.Migration

  def change do
    create table("entity_meta") do
      add(:sensors, :map)
      add(:sensor_types, :map)
      add(:assets, :map)
      add(:asset_types, :map)
      add(:projects, :map)
      add(:gateways, :map)
      add(:active_parameters, :map)

      # timestamps(type: :timestamptz)
    end
  end
end
