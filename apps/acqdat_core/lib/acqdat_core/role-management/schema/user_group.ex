defmodule AcqdatCore.Schema.RoleManagement.UserGroup do
  @moduledoc """
  Models a group in acqdat.
  """
  import Ecto.Query
  use AcqdatCore.Schema
  alias AcqdatCore.Schema.EntityManagement.Organisation
  alias AcqdatCore.Schema.RoleManagement.{User, Policy}
  alias AcqdatCore.Repo

  @type t :: %__MODULE__{}

  schema("acqdat_groups") do
    field(:name, :string, null: false)

    # associations
    belongs_to(:org, Organisation)
    many_to_many(:users, User, join_through: "acqdat_group_users", on_delete: :delete_all)
    many_to_many(:policies, Policy, join_through: "acqdat_group_policies", on_delete: :delete_all)

    timestamps(type: :utc_datetime)
  end

  @required ~w(name org_id)a
  @permitted @required

  def changeset(group, params) do
    group
    |> cast(params, @permitted)
    |> validate_required(@permitted)
    |> common_changeset()
    |> put_group_users(params.user_ids)
    |> put_group_policies(params.policy_ids)
  end

  def normal_changeset(group, params) do
    group
    |> cast(params, @permitted)
    |> validate_required(@permitted)
    |> common_changeset()
  end

  def common_changeset(changeset) do
    changeset
    |> assoc_constraint(:org)
    |> unique_constraint(:name,
      name: :acqdat_groups_name_org_id_index,
      message: "unique group name under organisation"
    )
  end

  defp put_group_users(changeset, user_ids) do
    case is_nil(user_ids) do
      false ->
        users = Repo.all(from(user in User, where: user.id in ^user_ids))
        put_assoc(changeset, :users, Enum.map(users, &change/1))

      true ->
        changeset
    end
  end

  defp put_group_policies(changeset, policy_ids) do
    case is_nil(policy_ids) do
      false ->
        policies = Repo.all(from(policy in Policy, where: policy.id in ^policy_ids))
        put_assoc(changeset, :policies, Enum.map(policies, &change/1))

      true ->
        changeset
    end
  end
end
