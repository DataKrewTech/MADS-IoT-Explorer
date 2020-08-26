defmodule AcqdatCore.Model.DashboardManagement.CommandWidget do
  @moduledoc """
  Exposes functions to work with command widgets.
  """
  alias AcqdatCore.DashboardManagement.Schema.CommandWidget
  alias AcqdatCore.Repo
  import Ecto.Query

  def create(params) do
    changeset = CommandWidget.changeset(%CommandWidget{}, params)
    Repo.insert(changeset)
  end

  def update(command_widget, %{"data_settings" => _data_settings} = params) do
    changeset = CommandWidget.changeset(command_widget, params)
    verify_update(Repo.update(changeset))
  end

  def update(command_widget, params) do
    changeset = CommandWidget.changeset(command_widget, params)
    Repo.update(changeset)
  end

  def get(id) when is_integer(id) do
    case Repo.get(CommandWidget, id) do
      nil ->
        {:error, "Command Widget not found"}

      command_widget ->
        {:ok, command_widget}
    end
  end

  def get(params) when is_map(params) do
    case Repo.get_by(CommandWidget, params) do
      nil ->
        {:error, "Command Widget not found"}

      command_widget ->
        {:ok, command_widget}
    end
  end

  def get_all_by_panel_id(panel_id) do
    query =
      from(
        widget in CommandWidget,
        where: widget.panel_id == ^panel_id
      )

    Repo.all(query)
  end

  def get_command_widget_types() do
    values = CommandWidgetSchemaEnum.__valid_values__()

    values
    |> Stream.filter(fn value -> is_atom(value) end)
    |> Enum.map(fn module ->
      %{
        name: module.widget_name,
        module: module,
        widget_parameters: module.widget_parameters,
        image_url: module.image_url,
        widget_type: module.widget_type
      }
    end)
  end

  def delete(command_widget) do
    Repo.delete(command_widget)
  end

  ################# private functions ###############

  defp verify_update({:ok, command_widget}) do
    command_widget = Repo.preload(command_widget, :gateway)
    command_widget.module.handle_command(command_widget)
    {:ok, command_widget}
  end

  defp verify_update({:error, _error} = error), do: error
end
