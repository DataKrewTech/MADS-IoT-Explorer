defmodule AcqdatApi.DashboardManagement.CommandWidget do
  import AcqdatApiWeb.Helpers
  alias AcqdatCore.Model.DashboardManagement.CommandWidget
  alias Ecto.Multi
  alias AcqdatCore.Repo
  alias AcqdatCore.Model.DashboardManagement.Panel, as: PanelModel

  defdelegate get_command_widget_types(), to: CommandWidget
  defdelegate update(widget_type, params), to: CommandWidget
  defdelegate delete(widget_id), to: CommandWidget
  defdelegate get(id), to: CommandWidget

  def create(params) do
    Multi.new()
    |> Multi.run(:create_widget, fn _, _changes ->
      CommandWidget.create(params)
    end)
    |> Multi.run(:update_panel_widget_layout, fn _, %{create_widget: widget} ->
      widget = widget |> Repo.preload([:panel])
      widget_layouts = compute_panel_widget_layout(widget)
      PanelModel.update(widget.panel, %{widget_layouts: widget_layouts})
    end)
    |> run_transaction()
  end

  defp run_transaction(multi_query) do
    result = Repo.transaction(multi_query)

    case result do
      {:ok, %{create_widget: widget, update_panel_widget_layout: _panel}} ->
        {:ok, widget}

      {:error, failed_operation, failed_value, _changes_so_far} ->
        case failed_operation do
          :create_widget -> verify_error_changeset({:error, failed_value})
          :update_panel_widget_layout -> verify_error_changeset({:error, failed_value})
        end
    end
  end

  defp verify_error_changeset({:error, changeset}) do
    {:error, %{error: extract_changeset_error(changeset)}}
  end

  defp compute_panel_widget_layout(widget) do
    {width, height, type} = {25, 30, "command_widget"}
    widget_layouts = widget.panel.widget_layouts

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

    Map.put(widget_layouts || %{}, "#{widget.id}", computed_widget_layout)
  end
end
