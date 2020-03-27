defmodule AcqdatCore.Schema.Organisation do
  @moduledoc """
  Models a Organisation in our acqdat system which will contain the assets or gateways attached to those assets.

  A organisation is the topmost node of the heirarchy and will not have any parent.
  """
  use AcqdatCore.Schema

  # use AsNestedSet, scope: [:id]
  @typedoc """
  `uuid`: A universally unique id to identify the Organisation.
  `name`: Name for easy identification of the Organisation.
  """
  @type t :: %__MODULE__{}

  schema("acqdat_organisation") do
    field(:uuid, :string)
    field(:name, :string)
    field(:metadata, :map)
    field(:description, :string)

    timestamps(type: :utc_datetime)
  end

  @required_params ~w(name uuid)a
  @optional_params ~w(description metadata)a

  @permitted @required_params ++ @optional_params

  @spec changeset(
          __MODULE__.t(),
          map
        ) :: Ecto.Changeset.t()
  def changeset(%__MODULE__{} = organisation, params) do
    organisation
    |> cast(params, @permitted)
    |> add_uuid()
    |> validate_required(@required_params)
    |> common_changeset()
  end

  def update_changeset(%__MODULE__{} = organisation, params) do
    organisation
    |> cast(params, @permitted)
    |> validate_required(@update_required_params)
    |> common_changeset()
  end

  def common_changeset(changeset) do
    changeset
    |> unique_constraint(:name, name: :acqdat_organisation_name_index)
    |> unique_constraint(:uuid, name: :acqdat_organisation_uuid_index)
  end

  defp add_uuid(%Ecto.Changeset{valid?: true} = changeset) do
    changeset
    |> put_change(:uuid, UUID.uuid1(:hex))
  end
end
