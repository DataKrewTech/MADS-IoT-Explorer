defmodule AcqdatCore.Model.RoleManagement.UserPolicy do
  @moduledoc """
  Models a user policy in acqdat.
  """

  alias AcqdatCore.Schema.RoleManagement.UserPolicy
  alias AcqdatCore.Model.RoleManagement.Policy
  alias AcqdatCore.Model.RoleManagement.UserPolicy, as: UPModel
  alias AcqdatCore.Repo
  alias Ecto.Multi
  import Ecto.Query

  def create(params) do
    changeset = UserPolicy.changeset(%UserPolicy{}, params)
    Repo.insert(changeset)
  end

  def update(user, policies) do
    recieved_policy_ids = Policy.extract_policies(policies)
    user_present_policy_ids = extract_user_policy_ids(user)
    policies_to_add = recieved_policy_ids -- user_present_policy_ids
    policies_to_remove = user_present_policy_ids -- recieved_policy_ids

    Multi.new()
    |> Multi.run(:add_policy_to_user, fn _, _changes ->
      UPModel.add_policy_to_user(user, policies_to_add)
    end)
    |> Multi.run(:remove_policy_for_user, fn _, _changes ->
      UPModel.remove_policy_for_user(user, policies_to_remove)
    end)
    |> run_transaction
  end

  defp run_transaction(multi_query) do
    result = Repo.transaction(multi_query)

    case result do
      {:ok, %{add_policy_to_user: user, remove_policy_for_user: _panel}} ->
        {:ok, user}

      {:error, _, failed_value, _} ->
        {:error, failed_value}
    end
  end

  def add_policy_to_user(user, []) do
    {:ok, user |> Repo.preload([:user_group, :policies])}
  end

  def add_policy_to_user(user, policies_to_add) do
    user_policy_params =
      Enum.reduce(policies_to_add, [], fn policy_id, acc ->
        acc ++ [%{user_id: user.id, policy_id: policy_id}]
      end)

    Repo.insert_all(UserPolicy, user_policy_params)
    {:ok, user |> Repo.preload([:user_group, :policies])}
  end

  def remove_policy_for_user(user, []) do
    {:ok, user |> Repo.preload([:user_group, :policies])}
  end

  def remove_policy_for_user(user, policies_to_remove) do
    query =
      from(user_policy in UserPolicy,
        where: user_policy.user_id == ^user.id and user_policy.policy_id in ^policies_to_remove
      )

    Repo.delete_all(query)
    {:ok, user |> Repo.preload([:user_group, :policies])}
  end

  defp extract_user_policy_ids(user) do
    query =
      from(user_policy in UserPolicy,
        where: user_policy.user_id == ^user.id,
        select: user_policy.policy_id
      )

    Repo.all(query)
  end
end
