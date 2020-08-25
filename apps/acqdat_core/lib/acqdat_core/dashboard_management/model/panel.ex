defmodule AcqdatCore.Model.DashboardManagement.Panel do
  import Ecto.Query
  alias AcqdatCore.DashboardManagement.Schema.Panel
  # alias AcqdatCore.Model.DashboardManagement.WidgetInstance, as: WidgetInstanceModel
  # alias AcqdatCore.Model.DashboardManagement.CommandWidget
  alias AcqdatCore.Repo

  def create(params) do
    changeset = Panel.changeset(%Panel{}, params)
    Repo.insert(changeset)
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
end
