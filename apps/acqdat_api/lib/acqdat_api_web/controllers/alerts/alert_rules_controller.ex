defmodule AcqdatApiWeb.Alerts.AlertRulesController do
  @moduledoc """
  ALERT RULES API.
  All the basic structure which support our alert creation logic will be drawn from their respective alert rule.
  """
  use AcqdatApiWeb, :authorized_controller
  alias AcqdatApi.Alerts.AlertRules
  alias AcqdatApiWeb.Alerts.AlertRuleErrorHelper
  import AcqdatApiWeb.Helpers
  import AcqdatApiWeb.Validators.Alerts.AlertRules

  plug AcqdatApiWeb.Plug.LoadOrg
  plug AcqdatApiWeb.Plug.LoadAlertRules when action in [:update, :delete, :show]

  def create(conn, params) do
    case conn.status do
      nil ->
        changeset = verify_alert_rules(params)

        with {:extract, {:ok, data}} <- {:extract, extract_changeset_data(changeset)},
             {:create, {:ok, alert_rules}} <- {:create, AlertRules.create(data)} do
          conn
          |> put_status(200)
          |> render("alert_rules.json", %{alert_rules: alert_rules})
        else
          {:extract, {:error, error}} ->
            error = extract_changeset_error(error)
            send_error(conn, 400, error)

          {:create, {:error, message}} ->
            error = extract_changeset_error(message)
            send_error(conn, 400, error)
        end

      404 ->
        conn
        |> send_error(404, AlertRuleErrorHelper.error_message(:resource_not_found))

      401 ->
        conn
        |> send_error(401, AlertRuleErrorHelper.error_message(:unauthorized))
    end
  end

  def update(conn, params) do
    case conn.status do
      nil ->
        %{assigns: %{alert_rule: alert_rule}} = conn

        case AlertRules.update(alert_rule, params) do
          {:ok, alert_rules} ->
            conn
            |> put_status(200)
            |> render("alert_rules.json", %{alert_rules: alert_rules})

          {:error, alert_rule} ->
            error = extract_changeset_error(alert_rule)

            conn
            |> send_error(400, error)
        end

      404 ->
        conn
        |> send_error(404, AlertRuleErrorHelper.error_message(:resource_not_found))

      401 ->
        conn
        |> send_error(401, AlertRuleErrorHelper.error_message(:unauthorized))
    end
  end

  def delete(conn, _params) do
    case conn.status do
      nil ->
        %{assigns: %{alert_rule: alert_rule}} = conn

        case AlertRules.delete(alert_rule) do
          {:ok, alert_rules} ->
            conn
            |> put_status(200)
            |> render("alert_rules.json", %{alert_rules: alert_rules})

          {:error, alert_rule} ->
            error = extract_changeset_error(alert_rule)

            conn
            |> send_error(400, error)
        end

      404 ->
        conn
        |> send_error(404, AlertRuleErrorHelper.error_message(:resource_not_found))

      401 ->
        conn
        |> send_error(401, AlertRuleErrorHelper.error_message(:unauthorized))
    end
  end

  def index(conn, params) do
    changeset = verify_index_params(params)

    case conn.status do
      nil ->
        {:extract, {:ok, data}} = {:extract, extract_changeset_data(changeset)}
        {:list, alert_rules} = {:list, AlertRules.get_all(data)}

        conn
        |> put_status(200)
        |> render("index.json", alert_rules)

      404 ->
        conn
        |> send_error(404, AlertRuleErrorHelper.error_message(:resource_not_found))

      401 ->
        conn
        |> send_error(401, AlertRuleErrorHelper.error_message(:unauthorized))
    end
  end
end
