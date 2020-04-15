defmodule AcqdatCore.Schema.App do
  @moduledoc """
  Models a App in the system.
  """
  use AcqdatCore.Schema

  alias AcqdatCore.Schema.User

  @typedoc """
  `name`: Name of the app.
  """
  @type t :: %__MODULE__{}

  # TODO: Need to add more fields as per the future requirements
  schema("acqdat_apps") do
    field(:name, :string, null: false)
    field(:description, :string)
    field(:avatar, :string)

    many_to_many(:users, User, join_through: "app_user")

    timestamps(type: :utc_datetime)
  end

  @required_params ~w(name)a
  @optional_params ~w(description avatar)a

  @permitted @required_params ++ @optional_params

  @spec changeset(
          __MODULE__.t(),
          map
        ) :: Ecto.Changeset.t()
  def changeset(%__MODULE__{} = app, params) do
    app
    |> cast(params, @permitted)
    |> validate_required(@required_params)
  end
end
