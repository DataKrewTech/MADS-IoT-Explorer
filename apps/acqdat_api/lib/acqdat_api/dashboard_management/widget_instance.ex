defmodule AcqdatApi.DashboardManagement.WidgetInstance do
  import AcqdatApiWeb.Helpers
  alias AcqdatCore.Model.DashboardManagement.WidgetInstance, as: WidgetInstanceModel
  alias AcqdatCore.Widgets.Schema.Vendors.HighCharts

  defdelegate delete(widget_instance), to: WidgetInstanceModel

  defdelegate get_by_filter(widget_id, filter_month, start_date, end_date),
    to: WidgetInstanceModel

  def create(attrs, conn) do
    verify_widget(
      attrs
      |> widget_create_attrs()
      |> WidgetInstanceModel.create()
    )
  end

  def update(widget_instance, attrs) do
    verify_widget(WidgetInstanceModel.update(widget_instance, widget_create_attrs(attrs)))
  end

  ############################# private functions ###########################

  defp widget_create_attrs(%{
         label: label,
         dashboard_id: dashboard_id,
         widget_id: widget_id,
         series: series,
         settings: settings,
         visual_prop: visual_prop
       }) do
    %{
      label: label,
      dashboard_id: dashboard_id,
      widget_id: widget_id,
      series_data: series,
      widget_settings: settings,
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
