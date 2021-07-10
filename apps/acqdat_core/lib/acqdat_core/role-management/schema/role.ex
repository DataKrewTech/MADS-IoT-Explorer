defmodule AcqdatCore.Schema.RoleManagement.Role do
  @moduledoc """
  Model different Roles in our Application
  """

  use AcqdatCore.Schema
  @roles ~w(superadmin orgadmin member)s

  @typedoc """
  `name`: role name.
  `description`: roles description
  """
  @type t :: %__MODULE__{}

  schema("acqdat_roles") do
    field(:name, :string)
    field(:description, :string)
    timestamps(type: :utc_datetime)
  end

  @required_fields ~w(name)a
  @optional_fields ~w(description)a

  @permitted @required_fields ++ @optional_fields

  @spec changeset(__MODULE__.t(), map) :: Ecto.Changeset.t()
  def changeset(%__MODULE__{} = role, params) do
    role
    |> cast(params, @permitted)
    |> validate_required(@required_fields)
    |> validate_inclusion(:name, @roles)
    |> unique_constraint(:name, name: :acqdat_roles_name_index)
  end
end
