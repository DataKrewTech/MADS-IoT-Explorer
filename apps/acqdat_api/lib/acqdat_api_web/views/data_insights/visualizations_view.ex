defmodule AcqdatApiWeb.DataInsights.VisualizationsView do
  use AcqdatApiWeb, :view
  alias AcqdatApiWeb.DataInsights.VisualizationsView

  def render("type_detail.json", %{visualizations: visualization}) do
    %{
      name: visualization.name,
      type: visualization.type,
      module: visualization.module,
      visual_settings: visualization.visual_settings,
      data_settings: visualization.data_settings
    }
  end

  def render("create.json", %{visualization: visualization}) do
    %{
      id: visualization.id,
      fact_table_id: visualization.fact_table_id,
      name: visualization.name,
      type: visualization.type,
      module: visualization.module,
      visual_settings: visualization.visual_settings,
      data_settings: visualization.data_settings
    }
  end

  def render("all_types.json", %{types: types}) do
    %{
      visualizations: render_many(types, VisualizationsView, "type_detail.json")
    }
  end
end
