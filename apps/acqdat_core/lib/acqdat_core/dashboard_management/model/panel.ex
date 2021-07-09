defmodule AcqdatCore.Model.DashboardManagement.Panel do
  import Ecto.Query
  alias AcqdatCore.DashboardManagement.Schema.Panel
  alias AcqdatCore.Model.DashboardManagement.WidgetInstance, as: WidgetInstanceModel
  alias AcqdatCore.Model.DashboardManagement.CommandWidget
  alias AcqdatCore.Repo

  def create(params) do
    changeset = Panel.changeset(%Panel{}, params)
    Repo.insert(changeset)
  end

  def update(panel, params) do
    changeset = Panel.update_changeset(panel, params)
    Repo.update(changeset)
  end

  def get_by_id(id) when is_integer(id) do
    case Repo.get(Panel, id) do
      nil ->
        {:error, "panel with this id not found"}

      panel ->
        {:ok, panel}
    end
  end

  def get_with_widgets(id, %{"filter_metadata" => filter_metadata}) do
    case Repo.get(Panel, id) do
      nil ->
        {:error, "panel with this id not found"}

      panel ->
        filter_params =
          %{filter_metadata: transform_map(filter_metadata)} |> compute_filtered_params(panel)

        fetch_panel_widgets_data(panel, filter_params)
    end
  end

  def get_with_widgets(id) do
    case Repo.get(Panel, id) do
      nil ->
        {:error, "panel with this id not found"}

      panel ->
        filter_params = panel |> parse_filtered_params
        fetch_panel_widgets_data(panel, filter_params)
    end
  end

  def delete(panel) do
    Repo.delete(panel)
  end

  def delete_all(ids) when is_list(ids) do
    from(panel in Panel, where: panel.id in ^ids)
    |> Repo.delete_all()
  end

  defp fetch_panel_widgets_data(panel, filter_params) do
    widgets = WidgetInstanceModel.get_all_by_panel_id(panel.id, filter_params)
    command_widgets = CommandWidget.get_all_by_panel_id(panel.id)

    panel =
      panel
      |> Map.put(:widgets, widgets)
      |> Map.put(:command_widgets, command_widgets)

    {:ok, panel}
  end

  defp compute_filtered_params(%{filter_metadata: user_filter_metadata}, %{
         filter_metadata: panel_filter_metadata
       }) do
    from_date = user_filter_metadata[:from_date] || panel_filter_metadata.from_date
    to_date = user_filter_metadata[:to_date] || panel_filter_metadata.to_date
    aggregate_func = user_filter_metadata[:aggregate_func] || panel_filter_metadata.aggregate_func
    group_interval = user_filter_metadata[:group_interval] || panel_filter_metadata.group_interval

    group_interval_type =
      user_filter_metadata[:group_interval_type] || panel_filter_metadata.group_interval_type

    last = user_filter_metadata[:last] || panel_filter_metadata.last

    parse_filtered_params(%{
      filter_metadata: %{
        from_date: from_date,
        to_date: to_date,
        aggregate_func: aggregate_func,
        group_interval: group_interval,
        group_interval_type: group_interval_type,
        last: last
      }
    })
  end

  defp parse_filtered_params(%{
         filter_metadata: %{
           from_date: from_date,
           to_date: to_date,
           aggregate_func: aggr_fun,
           group_interval: grp_intv,
           group_interval_type: grp_intv_type,
           last: last
         }
       }) do
    %{from_date: from_date, to_date: to_date} = fetch_datetime_range(from_date, to_date, last)

    %{
      from_date: from_date,
      to_date: to_date,
      aggregate_func: aggr_fun,
      group_interval: grp_intv,
      group_interval_type: grp_intv_type
    }
  end

  defp parse_filtered_params(_) do
    %{
      from_date: Timex.shift(Timex.now(), months: -1),
      to_date: Timex.now(),
      aggregate_func: "max",
      group_interval: 1,
      group_interval_type: "hour",
      last: "30_day"
    }
  end

  defp fetch_datetime_range(from_date, to_date, last) when last == "custom" do
    %{from_date: from_unix(from_date), to_date: from_unix(to_date)}
  end

  defp fetch_datetime_range(_, _, last) do
    [interval, duration] = String.split(last, "_")
    {interval, _} = Integer.parse(interval)
    to_date = DateTime.utc_now()

    from_date = to_date |> from_date(duration, interval)

    %{from_date: from_date, to_date: to_date}
  end

  defp from_date(to_date, duration, interval) do
    duration = String.to_atom(duration <> "s")
    Timex.shift(to_date, [{duration, -interval}])
  end

  defp from_unix(datetime) do
    {:ok, res} = datetime |> DateTime.from_unix(:millisecond)
    res
  end

  defp transform_map(map) do
    for {key, val} <- map, into: %{}, do: {String.to_atom(key), val}
  end
end
