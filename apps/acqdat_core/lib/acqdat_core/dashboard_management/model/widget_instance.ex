defmodule AcqdatCore.Model.DashboardManagement.WidgetInstance do
  import Ecto.Query
  alias AcqdatCore.DashboardManagement.Schema.WidgetInstance
  alias AcqdatCore.Model.DashboardManagement.Panel
  alias AcqdatCore.Widgets.Schema.Vendors.HighCharts
  alias AcqdatCore.Repo
  alias Ecto.Multi

  def create(params) do
    changeset = WidgetInstance.changeset(%WidgetInstance{}, params)
    Repo.insert(changeset)
  end

  def update(widget_instance, params) do
    changeset = WidgetInstance.update_changeset(widget_instance, params)
    Repo.update(changeset)
  end

  def get_by_id(id) when is_integer(id) do
    case Repo.get(WidgetInstance, id) do
      nil ->
        {:error, "widget_instance with this id not found"}

      widget_instance ->
        {:ok, widget_instance}
    end
  end

  def get_all_by_panel_id(panel_id, filter_params) do
    widget_instances =
      from(widget_instance in WidgetInstance,
        preload: [:widget, :panel],
        where: widget_instance.panel_id == ^panel_id
      )
      |> Repo.all()

    Enum.reduce(widget_instances, [], fn widget, acc ->
      widget = widget |> HighCharts.fetch_highchart_details(filter_params)
      acc ++ [widget]
    end)
  end

  def get_by_filter(id, filter_params) when is_integer(id) do
    case Repo.get(WidgetInstance, id) |> Repo.preload([:widget, :panel]) do
      nil ->
        {:error, "widget instance with this id not found"}

      widget_instance ->
        filtered_params = parse_filtered_params(filter_params, widget_instance.panel)

        widget_instance = widget_instance |> HighCharts.fetch_highchart_details(filtered_params)

        {:ok, widget_instance}
    end
  end

  def delete(widget_instance) do
    widget_instance = widget_instance |> Repo.preload([:panel])

    Multi.new()
    |> Multi.run(:delete_widget_instance, fn _, _changes ->
      Repo.delete(widget_instance)
    end)
    |> Multi.run(:rmv_frm_layouts, fn _, %{delete_widget_instance: widget_instance} ->
      layout = widget_instance.panel.widget_layouts
      layout = Map.delete(layout || %{}, "#{widget_instance.id}")
      Panel.update(widget_instance.panel, %{widget_layouts: layout})
    end)
    |> run_transaction()
  end

  defp run_transaction(multi_query) do
    result = Repo.transaction(multi_query)

    case result do
      {:ok, %{delete_widget_instance: widget_instance, rmv_frm_layouts: _panel}} ->
        {:ok, widget_instance}

      {:error, failed_operation, failed_value, _changes_so_far} ->
        {:error, failed_value}
    end
  end

  defp parse_filtered_params(params, %{
         filter_metadata: %{
           from_date: from_date,
           to_date: to_date,
           aggregate_func: aggr_fun,
           group_interval: grp_intv,
           group_interval_type: grp_intv_type
         }
       }) do
    %{
      from_date:
        from_unix(
          if(params["from_date"], do: String.to_integer(params["from_date"]), else: from_date)
        ),
      to_date:
        from_unix(if(params["to_date"], do: String.to_integer(params["to_date"]), else: to_date)),
      aggregate_func: if(params["aggregate_func"], do: params["aggregate_func"], else: aggr_fun),
      group_interval: if(params["group_interval"], do: params["group_interval"], else: grp_intv),
      group_interval_type:
        if(params["group_interval_type"], do: params["group_interval_type"], else: grp_intv_type)
    }
  end

  defp parse_filtered_params(_, _) do
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
