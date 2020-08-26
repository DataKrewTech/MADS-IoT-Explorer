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

  def get_all(%{
        page_size: page_size,
        page_number: page_number,
        org_id: org_id,
        dashboard_id: dashboard_id
      }) do
    query =
      from(panel in Panel,
        where: panel.org_id == ^org_id and panel.dashboard_id == ^dashboard_id,
        order_by: panel.name
      )

    query |> Repo.paginate(page: page_number, page_size: page_size)
  end

  def get_with_widgets(id) when is_integer(id) do
    case Repo.get(Panel, id) do
      nil ->
        {:error, "panel with this id not found"}

      panel ->
        widgets = WidgetInstanceModel.get_all_by_panel_id(panel.id)
        command_widgets = CommandWidget.get_all_by_panel_id(panel.id)

        panel =
          panel
          |> Map.put(:widgets, widgets)
          |> Map.put(:command_widgets, command_widgets)

        {:ok, panel}
    end
  end

  def delete_all(ids) when is_list(ids) do
    from(panel in Panel, where: panel.id in ^ids)
    |> Repo.delete_all()
  end
end
