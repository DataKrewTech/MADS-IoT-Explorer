defmodule AcqdatApiWeb.Alerts.AlertFilterListingController do
  @moduledoc """
  Contains API related to listing of different parameters of alert table.
  """
  use AcqdatApiWeb, :authorized_controller
  alias AcqdatApi.Alerts.AlertRules
  alias AcqdatApi.Alerts.AlertFilterListing
  alias AcqdatApiWeb.Alerts.AlertErrorHelper
  import AcqdatApiWeb.Helpers
  import AcqdatApiWeb.Validators.Alerts.AlertFilterListing

  plug AcqdatApiWeb.Plug.LoadOrg

  def alert_rule_listing(conn, params) do
    changeset = verify_index_params(params)

    case conn.status do
      nil ->
        {:extract, {:ok, data}} = {:extract, extract_changeset_data(changeset)}
        {:list, alert_rules} = {:list, AlertRules.get_all(data)}

        conn
        |> put_status(200)
        |> render("alert_rules.json", %{alert_rules: alert_rules})

      404 ->
        conn
        |> send_error(404, AlertErrorHelper.error_message(:resource_not_found))

      401 ->
        conn
        |> send_error(401, AlertErrorHelper.error_message(:unauthorized))
    end
  end

  def alert_app_listing(conn, _) do
    app = AlertFilterListing.list_app()

    conn
    |> put_status(200)
    |> render("apps.json", %{apps: app})
  end

  def alert_status_listing(conn, _) do
    status = AlertFilterListing.list_status()

    conn
    |> put_status(200)
    |> render("status.json", %{status: status})
  end
end
