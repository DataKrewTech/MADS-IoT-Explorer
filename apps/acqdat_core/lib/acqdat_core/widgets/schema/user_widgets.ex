defmodule AcqdatCore.Widgets.Schema.UserWidgets do
  @moduledoc """
  Models a User Widget in the system.

  To handle a widget assigned to a particular user.
  """

  use AcqdatCore.Schema
  alias AcqdatCore.Widgets.Schema.Widget
  alias AcqdatCore.Schema.RoleManagement.User

  @typedoc """
  `widget_id`: widget table reference
  `user_id`: user table reference
  """

  @type t :: %__MODULE__{}

  schema("acqdat_user_widgets") do
    belongs_to(:widget, Widget, on_replace: :delete)
    belongs_to(:user, User, on_replace: :delete)

    timestamps(type: :utc_datetime)
  end

  @permitted ~w(user_id widget_id)a

  @spec changeset(
          __MODULE__.t(),
          map
        ) :: Ecto.Changeset.t()
  def changeset(%__MODULE__{} = sensor, params) do
    sensor
    |> cast(params, @permitted)
    |> validate_required(@permitted)
    |> common_changeset()
  end

  def common_changeset(changeset) do
    changeset
    |> assoc_constraint(:widget)
    |> assoc_constraint(:user)
    |> unique_constraint(:name, name: :unique_widget_per_user)
  end
end
