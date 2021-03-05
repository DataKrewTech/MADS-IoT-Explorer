defmodule AcqdatCore.Repo.Migrations.AddChartCategoryToVisualizations do
  use Ecto.Migration

  def change do
  	alter table("acqdat_visualizations") do
      add(:chart_category, :string)
    end
  end
end
