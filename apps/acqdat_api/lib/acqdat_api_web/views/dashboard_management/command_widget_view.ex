defmodule AcqdatApiWeb.DashboardManagement.CommandWidgetView do
  use AcqdatApiWeb, :view

  def render("command_widget_types.json", %{command_widget_types: command_widget_types}) do
    %{
      command_widget_types:
        render_many(command_widget_types, __MODULE__, "command_widget_type.json")
    }
  end

  def render("command_widget_type.json", %{command_widget: cw_type}) do
    %{
      name: cw_type.name,
      module: cw_type.module,
      widget_parameters: cw_type.widget_parameters,
      image_url: cw_type.image_url,
      widget_type: cw_type.widget_type
    }
  end

  def render("show.json", %{command_widget: command_widget}) do
    %{
      id: command_widget.id,
      uuid: command_widget.uuid,
      gateway_id: command_widget.gateway_id,
      dashboard_id: command_widget.dashboard_id,
      label: command_widget.label,
      data_settings: command_widget.data_settings,
      visual_settings: command_widget.visual_settings,
      command_widget_type: command_widget.command_widget_type,
      module: command_widget.module,
      properties: command_widget.properties
    }
  end
end
