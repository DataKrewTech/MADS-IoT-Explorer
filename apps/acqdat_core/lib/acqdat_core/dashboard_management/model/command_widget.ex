defmodule AcqdatCore.Model.DashboardManagement.CommandWidget do
  @moduledoc """
  Exposes functions to work with command widgets.
  """
  alias AcqdatCore.DashboardManagement.Schema.CommandWidget
  alias AcqdatCore.Repo

  def create(params) do
    changeset = CommandWidget.changeset(%CommandWidget{}, params)
    Repo.insert(changeset)
  end

  def update(command_widget, %{"data_settings" => _data_settings} = params) do
    changeset = CommandWidget.changeset(command_widget, params)
    {:ok, command_widget} = Repo.update(changeset)
    command_widget.module.handle_command(command_widget)
    command_widget
  end

  def update(command_widget, params) do
    changeset = CommandWidget.changeset(command_widget, params)
    Repo.update(changeset)
  end

  def get(id) when is_integer(id) do

  end

  def get_all_by_dashboard_id(dashboard_id) do

  end

  def get_command_widget_types() do
    values = CommandWidgetSchemaEnum.__valid_values__()
    values
    |> Stream.filter(fn value -> is_atom(value) end)
    |> Enum.map(fn module ->
      %{
        name: module.widget_name,
        module: module,
        widget_parameters: module.widget_parameters
      }
    end)
  end
end
