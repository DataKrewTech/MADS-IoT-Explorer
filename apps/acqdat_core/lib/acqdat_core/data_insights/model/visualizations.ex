defmodule AcqdatCore.Model.DataInsights.Visualizations do
  alias AcqdatCore.DataInsights.Schema.Visualizations
  alias AcqdatCore.Model.Helper, as: ModelHelper
  alias AcqdatCore.Repo
  import Ecto.Query

  def create(params) do
    changeset = Visualizations.changeset(%Visualizations{}, params)
    Repo.insert(changeset)
  end

  def get(id) do
    case Repo.get(Visualizations, id) do
      nil ->
        {:error, "Visualization not found"}

      visualizations ->
        {:ok, visualizations}
    end
  end

  def get_all_visualization_types() do
    values = VisualizationsModuleSchemaEnum.__valid_values__()

    values
    |> Stream.filter(fn value -> is_atom(value) end)
    |> Enum.map(fn module ->
      %{
        name: module.visualization_name,
        type: module.visualization_type,
        module: module,
        visual_settings: module.visual_settings,
        data_settings: module.data_settings
      }
    end)
  end

  def delete(visualizations) do
    Repo.delete(visualizations)
  end
end
