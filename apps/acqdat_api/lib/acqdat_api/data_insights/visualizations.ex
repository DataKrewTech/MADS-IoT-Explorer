defmodule AcqdatApi.DataInsights.Visualizations do
  alias AcqdatCore.Model.DataInsights.Visualizations

  defdelegate get_all_visualization_types(), to: Visualizations
  defdelegate get_all(params), to: Visualizations
  defdelegate create(params), to: Visualizations

  def gen_data(visualization_id) do
    case Visualizations.get(visualization_id) do
      {:ok, visualization} ->
        module = visualization.module
        module.data_prop_gen(visualization)

      {:error, message} ->
        {:error, message}
    end
  end
end
