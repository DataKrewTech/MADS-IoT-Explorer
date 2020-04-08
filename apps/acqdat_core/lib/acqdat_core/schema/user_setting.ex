defmodule AcqdatCore.Schema.UserSetting do
  @moduledoc """
  Models a UserSetting in the system.

  It will include all the user_settings related dat of users

  It has two important categories:
  - `data_settings`
  - `visual_settings`

  **Data Settings**
  The data settings holds following things:
  - `last_login_time` : date_time
  - `latitude` : float
  - `longitude` : float

  **Visual Settings**
  The Visual Settings holds following things:
  - `recently_visited_apps` : array
  - `taskbar_pos` : string
  - `desktop_wallpaper` : string
  - `desktop_app_shortcuts` : array
  """

  use AcqdatCore.Schema
  alias AcqdatCore.Schema.User

  @typedoc """
  `visual_settings`: holds visualization related user's settings
  `data_settings`: holds data related user's settings
  """

  @type t :: %__MODULE__{}

  schema "user_settings" do
    # column_mappings
    field(:data_settings, :map)
    field(:visual_settings, :map)

    # associations
    belongs_to(:user, User)

    timestamps()
  end

  @required ~w(user_id)a
  @optional ~w(data_settings visual_settings)a
  @permitted @required ++ @optional

  @spec changeset(
          __MODULE__.t(),
          map
        ) :: Ecto.Changeset.t()
  def changeset(%__MODULE__{} = user_setting, params) do
    user_setting
    |> cast(params, @permitted)
    |> validate_required(@required)
  end
end
