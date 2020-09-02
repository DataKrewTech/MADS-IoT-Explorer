defmodule AcqdatCore.Model.DashboardExport.DashboardExport do
  @moduledoc """
  Models for dashboard export
  """
  import Ecto.Query
  alias AcqdatCore.DashboardExport.Schema.DashboardExport
  alias AcqdatCore.Repo

  def create(params) do
    changeset = DashboardExport.changeset(%DashboardExport{}, params)
    Repo.insert(changeset)
  end

  def generate_token(dashboard_uuid) do
    Phoenix.Token.sign(AcqdatApiWeb.Endpoint, "dashboard_uuid", dashboard_uuid)
  end

  def verify_token(token) do
    Phoenix.Token.verify(AcqdatApiWeb.Endpoint, "dashboard_uuid", token)
  end

  def verify_uuid_and_token(uuid, token) do
    query =
      from(dashboard_export in DashboardExport,
        where: dashboard_export.dashboard_uuid == ^uuid and dashboard_export.token == ^token
      )

    case List.first(Repo.all(query)) do
      nil -> {:error, "Unauthorized"}
      dashboard -> {:ok, dashboard}
    end
  end
end
