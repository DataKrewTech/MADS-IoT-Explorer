defmodule AcqdatApiWeb.NotificationPolicyView do
  use AcqdatApiWeb, :view
  alias AcqdatApiWeb.NotificationPolicyView

  def render("policies.json", %{notification_policy: {:policies, policies}}) do
    %{
      policy_name: policies.policy_name,
      preferences_name: policies.preferences.name,
      rule_data: policies.preferences.rule_data,
      rule_name: policies.rule_name
    }
  end

  def render("policy.json", %{policies: policies}) do
    %{
      policy_list: render_many(%{policies: policies}, NotificationPolicyView, "policies.json")
    }
  end
end
