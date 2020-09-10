defmodule AcqdatApi.DashboardManagement.Dashboard do
  import AcqdatApiWeb.Helpers
  alias Ecto.Multi
  alias AcqdatCore.Repo
  alias AcqdatCore.Model.DashboardManagement.Dashboard, as: DashboardModel
  alias AcqdatCore.Model.DashboardManagement.Panel, as: PanelModel

  defdelegate get_all(data), to: DashboardModel
  defdelegate get_with_panels(dashboard_id), to: DashboardModel
  defdelegate update(dashboard, data), to: DashboardModel
  defdelegate delete(dashboard), to: DashboardModel
  defdelegate get_by_uuid(uuid), to: DashboardModel

  def create(attrs) do
    %{
      name: name,
      description: description,
      org_id: org_id,
      avatar: avatar,
      settings: settings
    } = attrs

    dashboard_params = %{
      name: name,
      description: description,
      org_id: org_id,
      avatar: avatar,
      settings: settings || %{}
    }

    create_dashboard(dashboard_params)
  end

  ############################# private functions ###########################

  defp create_dashboard(params) do
    Multi.new()
    |> Multi.run(:create_dashboard, fn _, _changes ->
      DashboardModel.create(params)
    end)
    |> Multi.run(:create_home_panel, fn _, %{create_dashboard: dashboard} ->
      PanelModel.create(%{
        name: "Home",
        org_id: dashboard.org_id,
        dashboard_id: dashboard.id,
        filter_metadata: %{from_date: from_date}
      })
    end)
    |> run_transaction()
  end

  defp run_transaction(multi_query) do
    result = Repo.transaction(multi_query)

    case result do
      {:ok, %{create_dashboard: dashboard, create_home_panel: _panel}} ->
        verify_dashboard({:ok, dashboard})

      {:error, failed_operation, failed_value, _changes_so_far} ->
        case failed_operation do
          :create_dashboard -> verify_error_changeset({:error, failed_value})
          :create_home_panel -> verify_error_changeset({:error, failed_value})
        end
    end
  end

  defp verify_dashboard({:ok, dashboard}) do
    dashboard = Repo.preload(dashboard, [:panels, :dashboard_export])
    {:ok, dashboard}
  end

  defp verify_dashboard({:error, dashboard}) do
    {:error, %{error: extract_changeset_error(dashboard)}}
  end

  defp verify_error_changeset({:error, changeset}) do
    {:error, %{error: extract_changeset_error(changeset)}}
  end

  defp from_date do
    DateTime.to_unix(Timex.shift(DateTime.utc_now(), months: -1), :millisecond)
  end
end
