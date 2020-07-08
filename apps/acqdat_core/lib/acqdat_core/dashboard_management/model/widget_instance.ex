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
      widget = widget |> add_series_data()
      acc ++ [widget]
    end)
  end

  def get_by_id(id) when is_integer(id) do
    case Repo.get(WidgetInstance, id) do
      nil ->
        {:error, "widget instance with this id not found"}

      widget_instance ->
        widget_instance = widget_instance |> add_series_data()
        {:ok, widget_instance}
    end
  end

  defp add_series_data(widget_instance) do
    widget_instance
    |> Map.put(:data, HighCharts.arrange_series_structure(widget_instance.series_data))
  end
end
