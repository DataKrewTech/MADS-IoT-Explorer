defmodule AcqdatApi.DashboardManagement.Dashboard do
  alias AcqdatCore.Model.DashboardManagement.Dashboard, as: DashboardModel
  import AcqdatApiWeb.Helpers

  defdelegate get_all(data), to: DashboardModel
  defdelegate get_with_widgets(dashboard_id), to: DashboardModel
  defdelegate update(dashboard, data), to: DashboardModel
  defdelegate delete(dashboard), to: DashboardModel

  def create(attrs) do
    %{
      name: name,
      description: description,
      project_id: project_id,
      org_id: org_id,
      settings: settings
    } = attrs

    dashboard_params = %{
      name: name,
      description: description,
      project_id: project_id,
      org_id: org_id,
      settings: settings
    }

    verify_dashboard(DashboardModel.create(dashboard_params))
  end

  defp verify_dashboard({:ok, dashboard}) do
    {:ok, dashboard}
  end

  defp verify_dashboard({:error, dashboard}) do
    {:error, %{error: extract_changeset_error(dashboard)}}
  end
end
