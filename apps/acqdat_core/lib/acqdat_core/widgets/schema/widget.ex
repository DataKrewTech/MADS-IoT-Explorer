defmodule AcqdatCore.Widgets.Schema.Widget do
  @moduledoc """
  Widgets are used for creating visualizations from data sources.

  A widget has two important properties along with others:
  - `data_settings`
  - `visual_settings`

  **Data Settings**
  The data settings holds properties of data source which would be
  shown by an instance of the specific widget.
  A data source would be put on different axes for a widget. A data source
  is a columnar for an axes.

  **Visual Settings**
  Visual Settings hold the keys that can be set for the particular widget.
  The keys are defined by module for a particular vendor the information
  is derived from widget_type to which the widget belongs.
  """

  use AcqdatCore.Schema
  alias AcqdatCore.Widgets.Schema.WidgetType
  alias AcqdatCore.Widgets.Schema.Widget.DataSettings
  alias AcqdatCore.Widgets.Schema.Widget.VisualSettings

  @typedoc """
  `label`: widget name
  `uuid`: unique number
  `image_url`: holds the image url for a widget
  `default_values`: holds initial values for keys defined in data and visual
    settings
  `category`: category of the widget
  `policies`: policy of that widget
  `properties`: properties of a widget
  `visual_settings`: holds visualization related settings
  `data_settings`: holds data related settings for a widget
  """

  @classifications ~w(timeseries latest standard)s
  @type t :: %__MODULE__{}

  schema("acqdat_widgets") do
    field(:label, :string, null: false)
    field(:properties, :map)
    field(:uuid, :string)
    field(:image_url, :string)
    field(:default_values, :map)
    field(:category, {:array, :string})
    field(:policies, :map)
    field(:classification, :string, default: "timeseries")

    # embedded associations
    embeds_many(:visual_settings, VisualSettings, on_replace: :delete)
    embeds_many(:data_settings, DataSettings)

    # associations
    belongs_to(:widget_type, WidgetType)

    timestamps(type: :utc_datetime)
  end

  @required ~w(label default_values widget_type_id)a
  @optional ~w(properties image_url policies category classification)a
  @permitted @required ++ @optional

  @spec changeset(
          __MODULE__.t(),
          map
        ) :: Ecto.Changeset.t()
  def changeset(%__MODULE__{} = widget, params) do
    widget
    |> cast(params, @permitted)
    |> add_uuid()
    |> cast_embed(:visual_settings, with: &VisualSettings.changeset/2)
    |> cast_embed(:data_settings, with: &DataSettings.changeset/2)
    |> validate_required(@required)
    |> validate_inclusion(:classification, @classifications)
  end

  @spec update_changeset(
          AcqdatCore.Widgets.Schema.Widget.t(),
          :invalid | %{optional(:__struct__) => none, optional(atom | binary) => any}
        ) :: Ecto.Changeset.t()
  def update_changeset(%__MODULE__{} = widget, params) do
    widget
    |> cast(params, @permitted)
    |> cast_embed(:visual_settings, with: &VisualSettings.changeset/2)
    |> cast_embed(:data_settings, with: &DataSettings.changeset/2)
    |> validate_required(@required)
    |> validate_inclusion(:classification, @classifications)
  end
end

defmodule AcqdatCore.Widgets.Schema.Widget.VisualSettings do
  @moduledoc """
  Embed schema for visual settings in widget

  ## Note
  - User controlled field holds whether user will fill in the values for the
  given key.
  - A field which is not controlled by the user should have it's value set in
  the value field. For user controlled fields it would be empty.
  """
  use AcqdatCore.Schema
  alias AcqdatCore.Widgets.Schema.Widget.VisualSettings

  embedded_schema do
    field(:key, :string)
    field(:data_type, :string)
    field(:source, :map)
    field(:value, :map)
    field(:user_controlled, :boolean, default: false)
    embeds_many(:properties, VisualSettings, on_replace: :delete)
  end

  @permitted ~w(key data_type source value user_controlled)a

  def changeset(%__MODULE__{} = settings, params) do
    settings
    |> cast(params, @permitted)
    |> cast_embed(:properties, with: &VisualSettings.changeset/2)
  end
end

defmodule AcqdatCore.Widgets.Schema.Widget.DataSettings do
  @moduledoc """
  Embed schema for data related settings in widget.
  """

  use AcqdatCore.Schema
  alias AcqdatCore.Widgets.Schema.Widget.DataSettings

  embedded_schema do
    field(:key, :string)
    field(:value, :map)
    field(:data_type, :string)
    embeds_many(:properties, DataSettings)
  end

  @permitted ~w(key value data_type)a

  def changeset(%__MODULE__{} = settings, params) do
    settings
    |> cast(params, @permitted)
    |> cast_embed(:properties, with: &DataSettings.changeset/2)
  end
end
