defmodule AcqdatApi.DataInsights.Visualizations do
  alias AcqdatCore.Model.DataInsights.Visualizations

  defdelegate get_all_visualization_types(), to: Visualizations
  defdelegate get_all(params), to: Visualizations
  defdelegate create(params), to: Visualizations
  defdelegate delete(visualization), to: Visualizations

  def gen_data(visualization_id) do
    case Visualizations.get(visualization_id) do
      {:ok, visualization} ->
        module = visualization.module

        case module.data_prop_gen(visualization) do
          {:ok, data} ->
            {:ok, Map.put(visualization, :gen_data, data)}

          {:error, message} ->
            {:error, message}
        end

      {:error, message} ->
        {:error, message}
    end
  end
end
