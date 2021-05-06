defmodule AcqdatApi.DashboardManagement.Panel do
  alias AcqdatCore.Model.DashboardManagement.Panel, as: PanelModel
  alias AcqdatCore.Model.DashboardManagement.Dashboard, as: DashboardModel
  import AcqdatApiWeb.Helpers

  defdelegate delete(panel), to: PanelModel
  defdelegate get_with_widgets(panel_id), to: PanelModel
  defdelegate update(panel, data), to: PanelModel

  def get_all(%{dashboard_id: dashboard_id}) do
    {:ok, dashboard} = DashboardModel.get_with_panels(dashboard_id)
    dashboard.panels
  end

  def create(attrs) do
    %{
      name: name,
      description: description,
      org_id: org_id,
      dashboard_id: dashboard_id,
      settings: settings,
      filter_metadata: filter_metadata,
      widget_layouts: widget_layouts,
      icon: icon
    } = attrs

    panel_params = %{
      name: name,
      description: description,
      org_id: org_id,
      dashboard_id: dashboard_id,
      settings: settings,
      icon: icon,
      filter_metadata: filter_metadata || %{from_date: from_date},
      widget_layouts: widget_layouts
    }

    verify_panel(PanelModel.create(panel_params))
  end

  defp verify_panel({:ok, panel}) do
    {:ok, panel}
  end

  defp verify_panel({:error, panel}) do
    {:error, %{error: extract_changeset_error(panel)}}
  end

  defp from_date do
    DateTime.to_unix(Timex.shift(DateTime.utc_now(), months: -1), :millisecond)
  end
end
