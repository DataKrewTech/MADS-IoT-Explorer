defmodule AcqdatCore.Model.RoleManagement.UserGroup do
  @moduledoc """
  Exposes APIs for handling groups.
  """
  import Ecto.Query
  alias AcqdatCore.Schema.RoleManagement.UserGroup
  alias AcqdatCore.Schema.RoleManagement.GroupPolicy
  alias AcqdatCore.Repo
  alias AcqdatCore.Model.Helper, as: ModelHelper

  def create(params) do
    changeset = UserGroup.changeset(%UserGroup{}, params)
    Repo.insert(changeset)
  end

  def update(%UserGroup{} = user_group, attrs \\ %{}) do
    user_group
    |> Repo.preload([:policies, :users])
    |> UserGroup.changeset(attrs)
    |> Repo.update()
  end

  def normal_update(%UserGroup{} = user_group, attrs \\ %{}) do
    user_group
    |> Repo.preload([:policies, :users])
    |> UserGroup.normal_changeset(attrs)
    |> Repo.update()
  end

  def get(id) when is_integer(id) do
    case Repo.get(UserGroup, id) do
      nil ->
        {:error, "User Group not found"}

      group ->
        {:ok, group}
    end
  end

  def extract_groups(ids) do
    query =
      from(group in UserGroup,
        where: group.id in ^ids,
        select: group.id
      )

    Repo.all(query)
  end

  def policies(group_id) do
    query =
      from(group_policy in GroupPolicy,
        where: group_policy.user_group_id == ^group_id,
        select: group_policy.policy_id
      )

    Repo.all(query)
  end

  def get_all(%{page_size: page_size, page_number: page_number, org_id: org_id}, preloads) do
    query =
      from(user_group in UserGroup,
        where: user_group.org_id == ^org_id
      )

    paginated_user_group_data =
      query |> order_by(:id) |> Repo.paginate(page: page_number, page_size: page_size)

    user_group_data_with_preloads = paginated_user_group_data.entries |> Repo.preload(preloads)

    ModelHelper.paginated_response(user_group_data_with_preloads, paginated_user_group_data)
  end

  def return_policies(
        %{org_id: org_id, group_ids: group_ids, page_size: page_size, page_number: page_number},
        preloads
      ) do
    query =
      from(user_group in UserGroup,
        where: user_group.org_id == ^org_id and user_group.id in ^group_ids
      )

    paginated_user_group_data =
      query |> order_by(:id) |> Repo.paginate(page: page_number, page_size: page_size)

    user_group_data_with_preloads = paginated_user_group_data.entries |> Repo.preload(preloads)

    ModelHelper.paginated_response(user_group_data_with_preloads, paginated_user_group_data)
  end

  def delete(%UserGroup{} = group) do
    case Repo.delete(group) do
      {:ok, group} -> {:ok, group |> Repo.preload([:policies, :users])}
      {:error, error} -> {:error, error}
    end
  end

  def return_multiple_user_groups(group_ids) do
    query =
      from(group in UserGroup,
        where: group.id in ^group_ids
      )

    Repo.all(query) |> Repo.preload(:policies)
  end
end
