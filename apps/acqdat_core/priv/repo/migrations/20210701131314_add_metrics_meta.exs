defmodule AcqdatCore.Repo.Migrations.AddMetricsMeta do
  use Ecto.Migration

  def change do
    create table("metrics_meta") do

      add(:entity_id, references("entity_meta", on_delete: :delete_all))
      add(:dashboard_id, references("dashboard_meta", on_delete: :delete_all))
      add(:data_insights_id, references("data_insights_meta", on_delete: :delete_all))
      add(:role_manager_id, references("role_manager_meta", on_delete: :delete_all))
    end
  end
end
