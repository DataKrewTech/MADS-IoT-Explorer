defmodule AcqdatApi.DashboardManagement.WidgetInstance do
  import AcqdatApiWeb.Helpers
  alias AcqdatCore.Repo
  alias AcqdatCore.Model.DashboardManagement.WidgetInstance, as: WidgetInstanceModel
  alias AcqdatCore.Widgets.Schema.Vendors.HighCharts

  defdelegate delete(widget_instance), to: WidgetInstanceModel
  defdelegate get_by_filter(widget_id, params), to: WidgetInstanceModel

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
    filtered_params = widget |> parse_filtered_params
    updated_widget = widget |> HighCharts.fetch_highchart_details(filtered_params)

    {:ok, updated_widget}
  end

  defp verify_widget({:error, widget}) do
    {:error, %{error: extract_changeset_error(widget)}}
  end

  defp parse_filtered_params(%{
         panel: %{
           filter_metadata: %{
             from_date: from_date,
             to_date: to_date,
             aggregate_func: aggr_fun,
             group_interval: grp_intv,
             group_interval_type: grp_intv_type
           }
         }
       }) do
    %{
      from_date: from_unix(from_date),
      to_date: from_unix(to_date),
      aggregate_func: aggr_fun,
      group_interval: grp_intv,
      group_interval_type: grp_intv_type
    }
  end

  defp parse_filtered_params(%{panel: panel}) do
    %{
      from_date: Timex.shift(Timex.now(), months: -1),
      to_date: Timex.now(),
      aggregate_func: "max",
      group_interval: 1,
      group_interval_type: "hour"
    }
  end

  defp from_unix(datetime) do
    {:ok, res} = datetime |> DateTime.from_unix(:millisecond)
    res
  end
end
