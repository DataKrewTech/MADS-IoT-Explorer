defmodule AcqdatApi.DashboardExport.DashboardExport do
  @moduledoc """
  All the helper function will be provided to the controller through this file
  """

  alias AcqdatCore.Model.DashboardExport.DashboardExport
  import AcqdatApiWeb.Helpers

  @url "https://mads.netlify.app/dashboards/"

  def create(params, dashboard) do
    token = DashboardExport.generate_token(dashboard.uuid)

    params =
      params_extraction(params)
      |> Map.put_new(:dashboard_uuid, dashboard.uuid)
      |> Map.put_new(:token, token)

    if params.is_secure == true and params.password != nil do
      verify_dashboard_export(DashboardExport.create(params))
    else
      if params.is_secure == false and params.password == nil do
        verify_dashboard_export(DashboardExport.create(params))
      else
        {:error, %{error: "wrong information provided"}}
      end
    end
  end

  def verify_dashboard_export({:ok, dashboard_export}) do
    {:ok, dashboard_export}
  end

  def verify_dashboard_export({:error, message}) do
    {:error, %{error: extract_changeset_error(message)}}
  end

  defp params_extraction(params) do
    Map.from_struct(params)
    |> Map.drop([:_id, :__meta__])
  end

  def generate_url(dashboard_export) do
    trailing_part =
      case dashboard_export.token do
        nil -> dashboard_export.dashboard_uuid
        _ -> dashboard_export.dashboard_uuid <> "?token=#{dashboard_export.token}"
      end

    @url <> trailing_part
  end
end
