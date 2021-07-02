defmodule AcqdatCore.Repo.Migrations.AddDataInsightsMeta do
  use Ecto.Migration

  def change do
    create table("data_insights_meta") do
      add(:fact_tables, :map)
      add(:visualisations, :map)
    end
  end
end
