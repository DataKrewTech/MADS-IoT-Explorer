defmodule AcqdatCore.Model.RoleManagement.GroupUser do
  @moduledoc """
  Models a user policy in acqdat.
  """

  alias AcqdatCore.Schema.RoleManagement.GroupUser
  alias AcqdatCore.Model.RoleManagement.GroupUser, as: GUModel
  alias AcqdatCore.Schema.RoleManagement.UserGroup
  alias AcqdatCore.Model.RoleManagement.UserGroup, as: UGModel
  alias AcqdatCore.Repo
  alias Ecto.Multi
  import Ecto.Query

  def create(params) do
    changeset = GroupUser.changeset(%GroupUser{}, params)
    Repo.insert(changeset)
  end

  def update(user, received_group_ids) do
    received_group_ids = UGModel.extract_groups(received_group_ids)
    present_group_ids = present_ids(user) |> Repo.all()
    groups_to_add = received_group_ids -- present_group_ids
    groups_to_remove = present_group_ids -- received_group_ids

    Multi.new()
    |> Multi.run(:add_user_to_group, fn _, _changes ->
      GUModel.add_user_to_group(user, groups_to_add)
    end)
    |> Multi.run(:remove_user_from_group, fn _, %{add_user_to_group: user} ->
      GUModel.remove_user_from_group(user, groups_to_remove)
    end)
    |> run_transaction()
  end

  defp run_transaction(multi_query) do
    result = Repo.transaction(multi_query)

    case result do
      {:ok, %{add_user_to_group: user, remove_user_from_group: _panel}} ->
        {:ok, user |> Repo.preload([:user_group, :policies])}

      {:error, failed_operation, failed_value, _changes_so_far} ->
        {:error, failed_value}
    end
  end

  defp present_ids(%{id: id, org_id: org_id}) do
    from(user_group in UserGroup,
      join: group_user in GroupUser,
      on: group_user.user_group_id == user_group.id,
      where: user_group.org_id == ^org_id and group_user.user_id == ^id,
      select: user_group.id
    )
  end

  def add_user_to_group(user, []) do
    {:ok, user |> Repo.preload([:user_group, :policies])}
  end

  def remove_user_from_group(user, []) do
    {:ok, user |> Repo.preload([:user_group, :policies])}
  end

  def add_user_to_group(user, group_ids) do
    user_group_params =
      Enum.reduce(group_ids, [], fn group_id, acc ->
        acc ++ [%{user_id: user.id, user_group_id: group_id}]
      end)

    Repo.insert_all(GroupUser, user_group_params)
    {:ok, user}
  end

  def remove_user_from_group(user, group_ids) do
    query =
      from(group_user in GroupUser,
        where: group_user.user_id == ^user.id and group_user.user_group_id in ^group_ids
      )

    Repo.delete_all(query)
    {:ok, user}
  end

  def return_groups(user) do
    query =
      from(group_user in GroupUser,
        where: group_user.user_id == ^user.id
      )

    Repo.all(query)
  end
end
