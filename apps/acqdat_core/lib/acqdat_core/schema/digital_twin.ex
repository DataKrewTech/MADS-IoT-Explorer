defmodule AcqdatCore.Schema.DigitalTwin do
  @moduledoc """
  Models a Digital Twin in the process.

  A Digital Twin will belongs to a particular site and process.
  """

  use AcqdatCore.Schema

  @unique_name_error "category exist for organisation"

  @typedoc """
  `name`: Name for easy identification of the digital twin.
  """
  @type t :: %__MODULE__{}

  schema("acqdat_digital_twins") do
    field(:name, :string)
    field(:metadata, :map)
    timestamps(type: :utc_datetime)
  end

  @required_params ~w(name)a
  @optional_params ~w(metadata)a
  @permitted @required_params ++ @optional_params
  @update_required_params ~w(name)a

  @spec changeset(
          __MODULE__.t(),
          map
        ) :: Ecto.Changeset.t()
  def changeset(%__MODULE__{} = digital_twin, params) do
    digital_twin
    |> cast(params, @permitted)
    |> validate_required(@required_params)
    |> unique_constraint(:name, message: @unique_name_error)
  end

  def update_changeset(%__MODULE__{} = digital_twin, params) do
    digital_twin
    |> cast(params, @permitted)
    |> validate_required(@update_required_params)
    |> unique_constraint(:name, message: @unique_name_error)
  end
end
