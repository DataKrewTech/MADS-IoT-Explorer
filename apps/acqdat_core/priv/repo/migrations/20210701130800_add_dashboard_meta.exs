defmodule AcqdatCore.Repo.Migrations.AddDashboardMeta do
  use Ecto.Migration

  def change do
    create table("dashboard_meta") do
      add(:dashboards, :map)
      add(:panels, :map)
      add(:widgets, :map)
    end
  end
end
