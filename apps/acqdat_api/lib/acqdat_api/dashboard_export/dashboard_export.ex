defmodule AcqdatApi.DashboardExport.DashboardExport do
  @moduledoc """
  All the helper function will be provided to the controller through this file
  """

  alias AcqdatCore.Model.DashboardExport.DashboardExport
  import AcqdatApiWeb.Helpers

  @url Application.get_env(:acqdat_api, :frontend_url)
  # @url "https://mads.netlify.app/dashboards/"

  def create(params, dashboard) do
    token = DashboardExport.generate_token(dashboard.uuid)
    url = generate_url(dashboard, token)

    params =
      params_extraction(params)
      |> Map.put_new(:dashboard_uuid, dashboard.uuid)
      |> Map.put_new(:token, token)
      |> Map.put_new(:dashboard_id, dashboard.id)
      |> Map.put_new(:url, url)

    if valid_params?(params) do
      verify_dashboard_export(DashboardExport.create(params))
    else
      {:error, %{error: "wrong information provided"}}
    end
  end

  def update(dashboard_export, params) do
    params = params_extraction(params)

    if valid_params?(params) do
      verify_dashboard_export(DashboardExport.update(dashboard_export, params))
    else
      {:error, %{error: "wrong information provided"}}
    end
  end

  ################# private functions ###############

  defp valid_params?(params) do
    (params.is_secure == true and params.password != nil) or
      (params.is_secure == false and params.password == nil)
  end

  defp verify_dashboard_export({:ok, dashboard_export}) do
    {:ok, dashboard_export}
  end

  defp verify_dashboard_export({:error, message}) do
    {:error, %{error: extract_changeset_error(message)}}
  end

  defp params_extraction(params) do
    Map.from_struct(params)
    |> Map.drop([:_id, :__meta__])
  end

  defp generate_url(dashboard, token) do
    trailing_part = dashboard.uuid <> "?token=#{token}"
    @url <> trailing_part
  end
end
