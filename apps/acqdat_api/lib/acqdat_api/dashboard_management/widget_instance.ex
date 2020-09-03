defmodule AcqdatApi.DashboardManagement.WidgetInstance do
  import AcqdatApiWeb.Helpers
  alias AcqdatCore.Repo
  alias AcqdatCore.Model.DashboardManagement.WidgetInstance, as: WidgetInstanceModel
  alias AcqdatCore.Widgets.Schema.Vendors.HighCharts

  defdelegate delete(widget_instance), to: WidgetInstanceModel
  defdelegate get_by_filter(widget_id), to: WidgetInstanceModel

  def create(attrs, conn) do
    verify_widget(
      attrs
      |> widget_create_attrs()
      |> WidgetInstanceModel.create()
    )
  end

  def update(widget_instance, attrs) do
    WidgetInstanceModel.update(widget_instance, attrs)
    |> verify_widget()
  end

  ############################# private functions ###########################

  defp widget_create_attrs(%{
         label: label,
         panel_id: panel_id,
         widget_id: widget_id,
         series_data: series_data,
         widget_settings: widget_settings,
         visual_properties: visual_properties
       }) do
    %{
      label: label,
      panel_id: panel_id,
      widget_id: widget_id,
      series_data: series_data,
      widget_settings: widget_settings,
      visual_properties: visual_properties
    }
  end

  defp verify_widget({:ok, widget}) do
    widget = widget |> Repo.preload([:widget, :panel])
    updated_widget = widget |> HighCharts.fetch_highchart_details()

    {:ok, updated_widget}
  end

  defp verify_widget({:error, widget}) do
    {:error, %{error: extract_changeset_error(widget)}}
  end
end
