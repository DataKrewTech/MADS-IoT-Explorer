defmodule AcqdatApi.DashboardManagement.Panel do
  alias AcqdatCore.Model.DashboardManagement.Panel, as: PanelModel
  import AcqdatApiWeb.Helpers

  defdelegate get_all(data), to: PanelModel
  defdelegate delete_all(ids), to: PanelModel
  defdelegate get_with_widgets(panel_id), to: PanelModel

  def create(attrs) do
    %{
      name: name,
      description: description,
      org_id: org_id,
      dashboard_id: dashboard_id,
      settings: settings,
      filter_metadata: filter_metadata,
      widget_layouts: widget_layouts
    } = attrs

    filter_metadata =
      unless filter_metadata == nil do
        filter_metadata
        |> Map.put("from_date", parse_date(filter_metadata["from_date"]))
        |> Map.put("to_date", parse_date(filter_metadata["to_date"]))
      end

    panel_params = %{
      name: name,
      description: description,
      org_id: org_id,
      dashboard_id: dashboard_id,
      settings: settings,
      filter_metadata: filter_metadata || %{},
      widget_layouts: widget_layouts
    }

    verify_panel(PanelModel.create(panel_params))
  end

  def update(panel, data) do
    filter_metadata = data["filter_metadata"] || %{}

    filter_metadata =
      unless filter_metadata == %{} do
        filter_metadata
        |> Map.put("from_date", parse_date(filter_metadata["from_date"]))
        |> Map.put("to_date", parse_date(filter_metadata["to_date"]))
      end

    data = data |> Map.put("filter_metadata", filter_metadata)
    PanelModel.update(panel, data)
  end

  defp verify_panel({:ok, panel}) do
    {:ok, panel}
  end

  defp verify_panel({:error, panel}) do
    {:error, %{error: extract_changeset_error(panel)}}
  end

  defp parse_date(date) do
    date
    |> Timex.parse!("{YYYY}-{0M}-{0D}")
  end
end
