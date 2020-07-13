defmodule AcqdatCore.Model.DashboardManagement.WidgetInstance do
  import Ecto.Query
  alias AcqdatCore.DashboardManagement.Schema.WidgetInstance
  alias AcqdatCore.Widgets.Schema.Vendors.HighCharts
  alias AcqdatCore.Repo

  def create(params) do
    changeset = WidgetInstance.changeset(%WidgetInstance{}, params)
    Repo.insert(changeset)
  end

  def get_all_by_dashboard_id(dashboard_id) do
    widget_instances =
      WidgetInstance |> where([widget], widget.dashboard_id == ^dashboard_id) |> Repo.all()

    Enum.reduce(widget_instances, [], fn widget, acc ->
      widget = widget |> HighCharts.fetch_highchart_details()
      acc ++ [widget]
    end)
  end

  def get_by_filter(id, filter_month \\ "1", start_date \\ "", end_date \\ "")
      when is_integer(id) do
    case Repo.get(WidgetInstance, id) do
      nil ->
        {:error, "widget instance with this id not found"}

      widget_instance ->
        widget_instance =
          widget_instance
          |> HighCharts.fetch_highchart_details(filter_month, start_date, end_date)

        {:ok, widget_instance}
    end
  end
end
