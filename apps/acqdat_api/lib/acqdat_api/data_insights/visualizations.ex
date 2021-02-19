defmodule AcqdatApi.DataInsights.Visualizations do
  alias AcqdatCore.Model.DataInsights.Visualizations

  defdelegate get_all_visualization_types(), to: Visualizations
end
