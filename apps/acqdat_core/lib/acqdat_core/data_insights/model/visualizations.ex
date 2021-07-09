defmodule AcqdatCore.Model.DataInsights.Visualizations do
  alias AcqdatCore.DataInsights.Schema.Visualizations
  alias AcqdatCore.Repo
  import Ecto.Query

  def create(params) do
    changeset = Visualizations.changeset(%Visualizations{}, params)
    Repo.insert(changeset)
  end

  def update(%Visualizations{} = visualizations, params) do
    changeset = Visualizations.update_changeset(visualizations, params)
    Repo.update(changeset)
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
        icon_id: module.icon_id,
        visual_settings: module.visual_settings,
        data_settings: module.data_settings
      }
    end)
  end

  def delete(visualizations) do
    Repo.delete(visualizations)
  end

  def get_all(%{
        page_size: page_size,
        page_number: page_number,
        project_id: project_id,
        org_id: org_id,
        fact_tables_id: fact_tables_id
      }) do
    query =
      from(visualization in Visualizations,
        preload: [creator: :user_credentials],
        where:
          visualization.org_id == ^org_id and
            visualization.project_id == ^project_id and
            visualization.fact_table_id == ^fact_tables_id,
        order_by: visualization.name
      )

    query |> Repo.paginate(page: page_number, page_size: page_size)
  end

  def get_all_count_for_project(%{
        project_id: project_id,
        org_id: org_id
      }) do
    query =
      from(visual in Visualizations,
        where:
          visual.org_id == ^org_id and
            visual.project_id == ^project_id,
        select: count(visual.id)
      )

    Repo.one(query)
  end
end
