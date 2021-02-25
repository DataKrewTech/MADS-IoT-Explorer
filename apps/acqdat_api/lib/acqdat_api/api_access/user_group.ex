defmodule AcqdatApi.ApiAccess.UserGroup do
  @moduledoc """
  All the helper function will be provided to the controller through this file
  """
  alias AcqdatCore.Model.RoleManagement.UserGroup
  alias AcqdatCore.Model.RoleManagement.Policy
  import AcqdatApiWeb.Helpers

  defdelegate get_all(data, preloads), to: UserGroup
  defdelegate get(id), to: UserGroup
  defdelegate delete(user_group), to: UserGroup
  defdelegate return_policies(data, preloads), to: UserGroup

  def create(params) do
    params = params_extraction(params)
    policy_ids = Policy.extract_policies(params.actions)
    params = Map.put_new(params, :policy_ids, policy_ids) |> Map.put_new(:user_ids, [])
    verify_group(UserGroup.create(params))
  end

  def update(group, params) do
    params = for {key, val} <- params, into: %{}, do: {String.to_atom(key), val}
    policy_ids = Policy.extract_policies(params.actions)
    # present_policy_ids = UserGroup.policies(group.id)
    # policy_ids = Enum.uniq(policy_ids ++ present_policy_ids)
    params = Map.put_new(params, :policy_ids, policy_ids)
    params = Map.put_new(params, :user_ids, [])
    verify_group(UserGroup.update(group, params))
  end

  defp verify_group({:ok, group}) do
    {:ok, group}
  end

  defp verify_group({:error, group}) do
    {:error, %{error: extract_changeset_error(group)}}
  end

  defp params_extraction(params) do
    Map.from_struct(params)
    |> Map.drop([:_id, :__meta__])
  end
end
