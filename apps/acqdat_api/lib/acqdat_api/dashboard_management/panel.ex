defmodule AcqdatApi.DashboardManagement.Panel do
  alias AcqdatCore.Model.DashboardManagement.Panel, as: PanelModel
  import AcqdatApiWeb.Helpers

  defdelegate get_all(data), to: PanelModel
  defdelegate delete(panel), to: PanelModel
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

    data = data |> Map.put("filter_metadata", filter_metadata)
    PanelModel.update(panel, data)
  end

  defp verify_panel({:ok, panel}) do
    {:ok, panel}
  end

  defp verify_panel({:error, panel}) do
    {:error, %{error: extract_changeset_error(panel)}}
  end
end
