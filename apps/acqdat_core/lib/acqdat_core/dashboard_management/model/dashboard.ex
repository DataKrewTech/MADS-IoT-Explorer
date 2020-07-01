defmodule AcqdatCore.Model.DashboardManagement.Dashboard do
  import Ecto.Query
  alias AcqdatCore.DashboardManagement.Schema.Dashboard
  alias AcqdatCore.Model.Helper, as: ModelHelper
  alias AcqdatCore.Repo

  def get_all(%{
        page_size: page_size,
        page_number: page_number,
        org_id: org_id,
        project_id: project_id
      }) do
    query =
      from(dashboard in Dashboard,
        where: dashboard.org_id == ^org_id and dashboard.project_id == ^project_id,
        order_by: dashboard.name
      )

    query |> Repo.paginate(page: page_number, page_size: page_size)
  end
end
