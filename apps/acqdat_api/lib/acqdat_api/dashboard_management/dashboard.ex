defmodule AcqdatApi.DashboardManagement.Dashboard do
  alias AcqdatCore.Model.DashboardManagement.Dashboard, as: DashboardModel
  import AcqdatApiWeb.Helpers

  defdelegate get_all(data), to: DashboardModel
end
