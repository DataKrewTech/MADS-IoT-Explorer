defmodule AcqdatCore.Model.RoleManagement.GroupPolicy do
  import Ecto.Query
  alias AcqdatCore.Schema.RoleManagement.GroupPolicy
  alias AcqdatCore.Repo

  def remove_policy_from_group(group_id, policy_ids) do
    query =
      from(group_policy in GroupPolicy,
        where: group_policy.user_group_id == ^group_id and group_policy.policy_id in ^policy_ids
      )

    Repo.delete_all(query)
  end
end
