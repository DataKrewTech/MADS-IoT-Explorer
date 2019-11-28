defmodule AcqdatApiWeb.NotificationPolicyView do
  use AcqdatApiWeb, :view
  alias AcqdatApiWeb.NotificationPolicyView

  def render("policy.json", %{notification_policy: policy}) do
    %{
      policy_name: policy.policy_name,
      preferences_name: policy.preferences.name,
      rule_data: policy.preferences.rule_data,
      rule_name: policy.rule_name
    }
  end

  def render("policies.json", %{policies: policies}) do
    %{
      policies: render_many(policies, NotificationPolicyView, "policy.json")
    }
  end
end
