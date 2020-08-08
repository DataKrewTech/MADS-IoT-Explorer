defmodule AcqdatApi.DashboardManagement.CommandWidget do
  alias AcqdatCore.Model.DashboardManagement.CommandWidget

  defdelegate get_command_widget_types(), to: CommandWidget
  defdelegate create(params), to: CommandWidget
  defdelegate update(widget_type, params), to: CommandWidget
  defdelegate delete(widget_id), to: CommandWidget
  defdelegate get(id), to: CommandWidget
end
