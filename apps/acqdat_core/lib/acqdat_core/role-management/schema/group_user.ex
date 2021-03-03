defmodule AcqdatCore.Schema.RoleManagement.GroupUser do
  @moduledoc """
  Models a group in acqdat.
  """
  use AcqdatCore.Schema
  alias AcqdatCore.Schema.RoleManagement.{User, UserGroup}

  @type t :: %__MODULE__{}

  schema("acqdat_group_users") do
    # associations
    belongs_to(:user_group, UserGroup)
    belongs_to(:user, User, on_replace: :delete)
  end

  @required ~w(user_id user_group_id)a
  @permitted @required

  def changeset(group, params) do
    group
    |> cast(params, @permitted)
    |> validate_required(@permitted)
    |> assoc_constraint(:user_group)
    |> assoc_constraint(:user)
    |> unique_constraint(:user_group_id,
      name: :acqdat_group_users_user_group_id_user_id_index,
      message: "unique user under one group"
    )
  end
end
