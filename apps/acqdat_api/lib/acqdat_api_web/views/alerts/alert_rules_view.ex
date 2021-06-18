defmodule AcqdatApiWeb.Alerts.AlertRulesView do
  use AcqdatApiWeb, :view
  alias AcqdatApiWeb.Alerts.AlertRulesView
  alias AcqdatCore.Alerts.Model.AlertRules

  def render("alert_rules.json", %{alert_rules: alert_rules}) do
    {:ok, severity} = AlertSeverityEnum.dump(alert_rules.severity)
    recepient_ids = AlertRules.send_alert(alert_rules)

    %{
      app: alert_rules.app,
      rule_name: alert_rules.rule_name,
      org_id: alert_rules.org_id,
      assignee_ids: alert_rules.assignee_ids,
      communication_medium: alert_rules.communication_medium,
      creator_id: alert_rules.creator_id,
      phone_numbers: alert_rules.phone_numbers,
      description: alert_rules.description,
      entity: alert_rules.entity,
      entity_id: alert_rules.entity_id,
      entity_parameters:
        render_one(alert_rules.entity_parameters, AlertRulesView, "parameter.json"),
      id: alert_rules.id,
      policy_name: alert_rules.policy_name,
      policy_type: alert_rules.policy_type,
      project_id: alert_rules.project_id,
      recepient_ids: render_many(recepient_ids, AlertRulesView, "recepient.json"),
      rule_parameters: alert_rules.rule_parameters,
      severity: severity,
      slug: alert_rules.slug,
      status: alert_rules.status,
      uuid: alert_rules.uuid,
      created_at: alert_rules.inserted_at
    }
  end

  def render("parameter.json", %{alert_rules: params}) do
    %{
      data_type: params.data_type,
      uuid: params.uuid,
      unit: params.unit,
      name: params.name
    }
  end

  def render("index.json", alert_rules) do
    %{
      alert_rules: render_many(alert_rules.entries, AlertRulesView, "alert_rules.json"),
      page_number: alert_rules.page_number,
      page_size: alert_rules.page_size,
      total_entries: alert_rules.total_entries,
      total_pages: alert_rules.total_pages
    }
  end

  def render("recepient.json", %{alert_rules: recepient}) do
    %{
      id: recepient.id,
      email: recepient.user_credentials.email
    }
  end
end
