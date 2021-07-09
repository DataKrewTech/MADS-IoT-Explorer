defmodule AcqdatApi.DashboardManagement.WidgetInstance do
  import AcqdatApiWeb.Helpers
  alias Ecto.Multi
  alias AcqdatCore.Repo
  alias AcqdatCore.Model.DashboardManagement.WidgetInstance, as: WidgetInstanceModel
  alias AcqdatCore.Model.DashboardManagement.Panel, as: PanelModel
  alias AcqdatCore.Widgets.Schema.Vendors.HighCharts

  defdelegate delete(widget_instance), to: WidgetInstanceModel
  defdelegate get_by_filter(widget_id, params), to: WidgetInstanceModel

  def create(attrs) do
    Multi.new()
    |> Multi.run(:create_widget, fn _, _ ->
      attrs
      |> widget_create_attrs()
      |> WidgetInstanceModel.create()
    end)
    |> Multi.run(:update_panel_widget_layout, fn _, %{create_widget: widget_instance} ->
      widget_instance = widget_instance |> Repo.preload([:widget, :panel])
      widget_layouts = compute_panel_widget_layout(widget_instance)
      PanelModel.update(widget_instance.panel, %{widget_layouts: widget_layouts})
    end)
    |> run_transaction()
    |> broadcast_to_channel(attrs)
  end

  def update(widget_instance, attrs) do
    WidgetInstanceModel.update(widget_instance, attrs)
    |> verify_widget()
  end

  ############################# private functions ###########################

  defp run_transaction(multi_query) do
    result = Repo.transaction(multi_query)

    case result do
      {:ok, %{create_widget: widget_instance, update_panel_widget_layout: _}} ->
        verify_widget({:ok, widget_instance})

      {:error, failed_operation, failed_value, _} ->
        case failed_operation do
          :create_widget -> verify_error_changeset({:error, failed_value})
          :update_panel_widget_layout -> verify_error_changeset({:error, failed_value})
        end
    end
  end

  defp verify_error_changeset({:error, changeset}) do
    {:error, %{error: extract_changeset_error(changeset)}}
  end

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

  defp widget_create_attrs(%{
         label: label,
         panel_id: panel_id,
         widget_id: widget_id,
         source_app: source_app,
         source_metadata: source_metadata,
         visual_properties: visual_properties
       }) do
    %{
      label: label,
      panel_id: panel_id,
      widget_id: widget_id,
      source_app: source_app,
      source_metadata: source_metadata,
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

  defp compute_panel_widget_layout(widget_instance) do
    {width, height, type} = fetch_widget_dimensional_data(widget_instance.widget.category)
    widget_layouts = widget_instance.panel.widget_layouts

    y_offset =
      if widget_layouts != nil do
        values = Map.values(widget_layouts)

        max_elem =
          values
          |> Enum.reduce(0, fn data, acc ->
            data["y"]

            if acc > data["y"] do
              acc
            else
              data["y"]
            end
          end)

        max_elem + 4
      else
        0
      end

    computed_widget_layout = %{
      "w" => width,
      "h" => height,
      "x" => 0,
      "y" => y_offset,
      "type" => type
    }

    Map.put(widget_layouts || %{}, "#{widget_instance.id}", computed_widget_layout)
  end

  defp fetch_widget_dimensional_data(widget_category) do
    case widget_category do
      ["card", "dynamic_card"] ->
        {15, 20, "dynamic_card"}

      ["card", "static_card"] ->
        {15, 10, "static_card"}

      ["card", "image_card"] ->
        {15, 20, "image_card"}

      ["pivot_table"] ->
        {25, 20, "pivot_table"}

      ["anychart", _] ->
        {25, 20, "anychart"}

      _ ->
        {25, 20, "highcharts"}
    end
  end

  defp broadcast_to_channel(data, %{panel_id: panel_id}) do
    AcqdatApiWeb.Endpoint.broadcast("panels:#{panel_id}", "out_put_res", %{
      data: data
    })

    data
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

  defp parse_filtered_params(%{panel: _}) do
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
