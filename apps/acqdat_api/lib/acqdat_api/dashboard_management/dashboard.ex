defmodule AcqdatApi.DashboardManagement.Dashboard do
  alias AcqdatCore.Model.DashboardManagement.Dashboard, as: DashboardModel
  import AcqdatApiWeb.Helpers

  defdelegate get_all(data), to: DashboardModel

  def create(attrs) do
    %{name: name, description: description, project_id: project_id, org_id: org_id} = attrs

    dashboard_params = %{
      name: name,
      description: description,
      project_id: project_id,
      org_id: org_id
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
