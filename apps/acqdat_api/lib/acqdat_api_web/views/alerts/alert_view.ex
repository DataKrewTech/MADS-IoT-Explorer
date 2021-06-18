defmodule AcqdatApiWeb.Alerts.AlertView do
  use AcqdatApiWeb, :view
  alias AcqdatApiWeb.Alerts.AlertView
  alias AcqdatCore.Alerts.Model.AlertRules

  def render("alert.json", %{alert: alert}) do
    recepient_ids = AlertRules.send_alert(alert)

    %{
      rule_name: alert.name,
      created_at: alert.inserted_at,
      app: alert.app,
      org_id: alert.org_id,
      assignee_ids: alert.assignee_ids,
      communication_medium: alert.communication_medium,
      creator_id: alert.creator_id,
      description: alert.description,
      entity_name: alert.entity_name,
      entity_id: alert.entity_id,
      rule_parameters: render_many(alert.rule_parameters, AlertView, "parameter.json"),
      id: alert.id,
      policy_name: alert.policy_name,
      policy_module_name: alert.policy_module_name,
      project_id: alert.project_id,
      recepient_ids: render_many(recepient_ids, AlertView, "recepient.json"),
      severity: alert.severity,
      status: alert.status
    }
  end

  def render("parameter.json", %{alert: params}) do
    %{
      name: params.name,
      data_type: params.data_type,
      entity_parameter_uuid: params.entity_parameter_uuid,
      entity_parameter_name: params.entity_parameter_name,
      value: params.value
    }
  end

  def render("index.json", alert) do
    %{
      alerts: render_many(alert.entries, AlertView, "alert.json"),
      page_number: alert.page_number,
      page_size: alert.page_size,
      total_entries: alert.total_entries,
      total_pages: alert.total_pages
    }
  end

  def render("recepient.json", %{alert: recepient}) do
    %{
      id: recepient.id,
      email: recepient.user_credentials.email
    }
  end
end
