defmodule AcqdatCore.Model.DashboardManagement.Dashboard do
  import Ecto.Query
  alias AcqdatCore.DashboardManagement.Schema.Dashboard
  alias AcqdatCore.Model.DashboardManagement.WidgetInstance, as: WidgetInstanceModel
  alias AcqdatCore.Repo

  def create(params) do
    changeset = Dashboard.changeset(%Dashboard{}, params)
    Repo.insert(changeset)
  end

  def update(dashboard, params) do
    changeset = Dashboard.update_changeset(dashboard, params)
    Repo.update(changeset)
  end

  def delete(dashboard) do
    Repo.delete(dashboard)
  end

  def get_by_id(id) when is_integer(id) do
    case Repo.get(Dashboard, id) do
      nil ->
        {:error, "dashboard with this id not found"}

      dashboard ->
        {:ok, dashboard}
    end
  end

  def get_with_widgets(id) when is_integer(id) do
    case Repo.get(Dashboard, id) do
      nil ->
        {:error, "dashboard with this id not found"}

      dashboard ->
        widgets = WidgetInstanceModel.get_all_by_dashboard_id(dashboard.id)
        dashboard = Map.put(dashboard, :widgets, widgets)
        {:ok, dashboard}
    end
  end

  def get_all(%{
        page_size: page_size,
        page_number: page_number,
        org_id: org_id,
        project_id: project_id
      }) do
    query =
      from(dashboard in Dashboard,
        where: dashboard.org_id == ^org_id and dashboard.project_id == ^project_id,
        order_by: dashboard.name
      )

    query |> Repo.paginate(page: page_number, page_size: page_size)
  end
end
