defmodule AcqdatApi.DashboardManagement.WidgetInstance do
  alias AcqdatCore.Model.DashboardManagement.WidgetInstance, as: WidgetInstanceModel
  import AcqdatApiWeb.Helpers

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
           series: series
         }, widget 
       ) do

    data_settings = parse_struct_to_map(widget.data_settings)
    visual_settings = parse_struct_to_map(widget.visual_settings)
    %{
      label: label,
      dashboard_id: dashboard_id,
      widget_id: widget_id,
      data_settings: data_settings,
      visual_settings: visual_settings,
      series_data: series
    }
  end

  defp parse_struct_to_map(settings) do
    Enum.map(settings, fn setting -> sample(Map.from_struct(setting)) end)
  end

  defp verify_widget({:ok, widget}) do
    {:ok, widget}
  end

  defp verify_widget({:error, widget}) do
    {:error, %{error: extract_changeset_error(widget)}}
  end

  #NOTE: Below code is for parsing and converting nested struct to nested map
  #taken_reference from here: https://elixirforum.com/t/convert-a-nested-struct-into-a-nested-map/23814/7

  defp sample(map), do: :maps.map(&do_sample/2, map)

  defp do_sample(_key, value), do: ensure_nested_map(value)

  defp ensure_nested_map(list) when is_list(list), do: Enum.map(list, &ensure_nested_map/1)

  # NOTE: In pattern-matching order of function guards is important!
  # @structs [Date, DateTime, NaiveDateTime, Time]
  # defp ensure_nested_map(%{__struct__: struct} = data) when struct in @structs, do: data

  defp ensure_nested_map(%{__struct__: _} = struct) do
    map = Map.from_struct(struct)
    :maps.map(&do_sample/2, map)
  end

  defp ensure_nested_map(data), do: data
end
