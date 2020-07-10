defmodule AcqdatApi.DashboardManagement.WidgetInstance do
  import AcqdatApiWeb.Helpers
  alias AcqdatCore.Model.DashboardManagement.WidgetInstance, as: WidgetInstanceModel
  alias AcqdatCore.Widgets.Schema.Vendors.HighCharts

  defdelegate get_by_filter(widget_id, filter_month, start_date, end_date),
    to: WidgetInstanceModel

  def create(attrs, conn) do
    verify_widget(
      attrs
      |> widget_create_attrs(conn.assigns.widget)
      |> WidgetInstanceModel.create()
    )
  end

  ############################# private functions ###########################

  defp widget_create_attrs(
         %{
           label: label,
           dashboard_id: dashboard_id,
           widget_id: widget_id,
           series: series,
           settings: settings,
           visual_prop: visual_prop
         },
         widget
       ) do
    %{
      label: label,
      dashboard_id: dashboard_id,
      widget_id: widget_id,
      series_data: series,
      visual_properties: visual_prop
    }
  end

  defp verify_widget({:ok, widget}) do
    updated_widget = widget |> HighCharts.fetch_highchart_details()

    {:ok, updated_widget}
  end

  defp verify_widget({:error, widget}) do
    {:error, %{error: extract_changeset_error(widget)}}
  end
end
