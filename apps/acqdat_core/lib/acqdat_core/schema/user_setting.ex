defmodule AcqdatCore.Schema.UserSetting do
  @moduledoc """
  Models a UserSetting in the system.

  It will include all the user_settings related data of users

  It has two important categories:
  - `data_settings`
  - `visual_settings`

  **Data Settings**
  The data settings holds following things:
  - `last_login_at` : date_time
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
  alias AcqdatCore.Schema.UserSetting.VisualSettings
  alias AcqdatCore.Schema.UserSetting.DataSettings

  @typedoc """
  `visual_settings`: holds visualization related user's settings
  `data_settings`: holds data related user's settings
  """

  @type t :: %__MODULE__{}

  schema "user_settings" do
    # associations
    belongs_to(:user, User)

    # embedded associations
    embeds_one(:visual_settings, VisualSettings)
    embeds_one(:data_settings, DataSettings)

    timestamps()
  end

  @required ~w(user_id)a
  @permitted @required

  @spec changeset(
          __MODULE__.t(),
          map
        ) :: Ecto.Changeset.t()
  def changeset(%__MODULE__{} = user_setting, params) do
    user_setting
    |> cast(params, @permitted)
    |> cast_embed(:visual_settings, with: &VisualSettings.changeset/2)
    |> cast_embed(:data_settings, with: &DataSettings.changeset/2)
    |> validate_required(@required)
    |> assoc_constraint(:user)
  end

  def update_changeset(%__MODULE__{} = user_setting, params) do
    user_setting
    |> cast(params, @permitted)
    |> cast_embed(:visual_settings, with: &VisualSettings.changeset/2)
    |> cast_embed(:data_settings, with: &DataSettings.changeset/2)
    |> validate_required(@required)
  end
end

defmodule AcqdatCore.Schema.UserSetting.DataSettings do
  @moduledoc """
  Embed schema for data related settings of user.
  """

  use AcqdatCore.Schema

  embedded_schema do
    field(:last_login_at, :utc_datetime)
    field(:latitude, :float)
    field(:longitude, :float)
  end

  @permitted ~w(last_login_at latitude longitude)a

  def changeset(%__MODULE__{} = settings, params) do
    settings
    |> cast(params, @permitted)
  end
end

defmodule AcqdatCore.Schema.UserSetting.VisualSettings do
  @moduledoc """
  Embed schema for visual related settings of user.
  """

  use AcqdatCore.Schema

  embedded_schema do
    field(:recently_visited_apps, {:array, :string})
    field(:taskbar_pos, :string)
    field(:desktop_wallpaper, :string)
    field(:desktop_app_shortcuts, {:array, :string})
  end

  @permitted ~w(recently_visited_apps taskbar_pos desktop_wallpaper desktop_app_shortcuts)a

  def changeset(%__MODULE__{} = settings, params) do
    settings
    |> cast(params, @permitted)
  end

  def update_changeset(%__MODULE__{} = user_setting, params) do
    user_setting
    |> cast(params, @params)
  end
end

defmodule AcqdatCore.Schema.UserSetting.DataSettings do
  @moduledoc """
  Embed schema for data related settings of user.
  """

  use AcqdatCore.Schema

  embedded_schema do
    field(:last_login_at, :utc_datetime)
    field(:latitude, :float)
    field(:longitude, :float)
  end

  @permitted ~w(last_login_at latitude longitude)a

  def changeset(%__MODULE__{} = settings, params) do
    settings
    |> cast(params, @permitted)
  end
end

defmodule AcqdatCore.Schema.UserSetting.VisualSettings do
  @moduledoc """
  Embed schema for visual related settings of user.
  """

  use AcqdatCore.Schema

  embedded_schema do
    field(:recently_visited_apps, {:array, :string})
    field(:taskbar_pos, :string)
    field(:desktop_wallpaper, :string)
    field(:desktop_app_shortcuts, {:array, :string})
  end

  @permitted ~w(recently_visited_apps taskbar_pos desktop_wallpaper desktop_app_shortcuts)a

  def changeset(%__MODULE__{} = settings, params) do
    settings
    |> cast(params, @permitted)
  end
end
