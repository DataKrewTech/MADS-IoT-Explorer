defmodule AcqdatCore.DashboardManagement.Schema.WidgetInstance do
  @moduledoc """
  WidgetInstance are instances of the class Widget, holding the same behaviour as that of widgets,
  but with different data-sources.

  It is used to model associations between dashboard and widget

  A widget_instance has four important properties along with others:
  - `data_settings`
  - `visual_settings`
  - `widget_settings`
  - `series_data`

  **Data Settings**
  The data settings holds properties of data source which would be
  shown by an instance of the specific widget.
  A data source would be put on different axes for a widget. A data source
  is a columnar for an axes.

  **Visual Settings**
  Visual Settings hold the keys that can be set for the particular widget instance.
  The keys are defined by module for a particular vendor the information
  is derived from widget_type to which the widget belongs.

  **Widget Settings**
  Widget Settings hold the settings which are widget specific on a prticular dashboard, like
  height, width of the widgets on the respective dashboard.

  **Series Data**
  Series Data holds mapping of all the series's axes and its associated datasources.
  Each and every axes will be associated with it respective datasource.
  Datasource will be of two categories:
  - `pds`: primary data source
  - `sds`: secondary data source
  """

  use AcqdatCore.Schema
  alias AcqdatCore.Widgets.Schema.Widget
  alias AcqdatCore.DashboardManagement.Schema.Dashboard
  alias AcqdatCore.DashboardManagement.Schema.WidgetInstance.DataSettings
  alias AcqdatCore.DashboardManagement.Schema.WidgetInstance.VisualSettings
  alias AcqdatCore.DashboardManagement.Schema.WidgetInstance.SeriesData

  @typedoc """
  `label`: widget_instance name
  `uuid`: unique number
  `default_values`: holds initial values for keys defined in data and visual
    settings
  `properties`: properties of a widget
  `visual_settings`: holds visualization related settings
  `data_settings`: holds data related settings for a widget
  `widget_settings`: holds widget specific settings on the respective dashboard
  """

  @type t :: %__MODULE__{}

  schema("acqdat_widget_instance") do
    field(:label, :string, null: false)
    field(:slug, :string, null: false)
    field(:widget_settings, :map)
    field(:properties, :map)
    field(:uuid, :string)
    field(:default_values, :map)

    # embedded associations
    embeds_many(:visual_settings, VisualSettings)
    embeds_many(:data_settings, DataSettings)
    embeds_many(:series_data, SeriesData)

    # associations
    belongs_to(:widget, Widget, on_replace: :delete)
    belongs_to(:dashboard, Dashboard, on_replace: :delete)

    timestamps(type: :utc_datetime)
  end

  @required ~w(label widget_id dashboard_id slug uuid)a
  @optional ~w(properties widget_settings default_values)a
  @permitted @required ++ @optional

  @spec changeset(
          __MODULE__.t(),
          map
        ) :: Ecto.Changeset.t()
  def changeset(%__MODULE__{} = widget_instance, params) do
    widget_instance
    |> cast(params, @permitted)
    |> assoc_constraint(:widget)
    |> assoc_constraint(:dashboard)
    |> add_slug()
    |> add_uuid()
    |> cast_embed(:visual_settings, with: &VisualSettings.changeset/2)
    |> cast_embed(:data_settings, with: &DataSettings.changeset/2)
    |> cast_embed(:series_data, with: &SeriesData.changeset/2)
    |> validate_required(@required)
    |> unique_constraint(:label,
      name: :unique_widget_name_per_dashboard,
      message: "unique widget label under dashboard"
    )
  end

  @spec update_changeset(
          AcqdatCore.Widgets.Schema.Widget.t(),
          :invalid | %{optional(:__struct__) => none, optional(atom | binary) => any}
        ) :: Ecto.Changeset.t()
  def update_changeset(%__MODULE__{} = widget, params) do
    widget
    |> cast(params, @permitted)
  end

  defp add_uuid(%Ecto.Changeset{valid?: true} = changeset) do
    changeset
    |> put_change(:uuid, UUID.uuid1(:hex))
  end

  defp add_slug(%Ecto.Changeset{valid?: true} = changeset) do
    changeset
    |> put_change(:slug, Slugger.slugify(random_string(12)))
  end

  defp random_string(length) do
    :crypto.strong_rand_bytes(length) |> Base.url_encode64() |> binary_part(0, length)
  end
end

defmodule AcqdatCore.DashboardManagement.Schema.WidgetInstance.VisualSettings do
  @moduledoc """
  Embed schema for visual settings in widget

  ## Note
  - User controlled field holds whether user will fill in the values for the
  given key.
  - A field which is not controlled by the user should have it's value set in
  the value field. For user controlled fields it would be empty.
  """
  use AcqdatCore.Schema
  alias AcqdatCore.DashboardManagement.Schema.WidgetInstance.VisualSettings

  embedded_schema do
    field(:key, :string)
    field(:data_type, :string)
    field(:source, :map)
    field(:value, :map)
    field(:user_controlled, :boolean, default: false)
    embeds_many(:properties, VisualSettings)
  end

  @permitted ~w(key data_type source value user_controlled)a

  def changeset(%__MODULE__{} = settings, params) do
    settings
    |> cast(params, @permitted)
    |> cast_embed(:properties, with: &VisualSettings.changeset/2)
  end
end

defmodule AcqdatCore.DashboardManagement.Schema.WidgetInstance.DataSettings do
  @moduledoc """
  Embed schema for data related settings in widget.
  """

  use AcqdatCore.Schema
  alias AcqdatCore.DashboardManagement.Schema.WidgetInstance.DataSettings

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

defmodule AcqdatCore.DashboardManagement.Schema.WidgetInstance.SeriesData do
  @moduledoc """
  Embed schema for Series Data and its data-sources.
  """

  use AcqdatCore.Schema
  alias AcqdatCore.DashboardManagement.Schema.WidgetInstance.Axes

  embedded_schema do
    field(:name, :string)
    field(:color, :string)
    embeds_many(:axes, Axes)
  end

  @permitted ~w(name color)a

  def changeset(%__MODULE__{} = series, params) do
    series
    |> cast(params, @permitted)
    |> cast_embed(:axes, with: &Axes.changeset/2)
  end
end

defmodule AcqdatCore.DashboardManagement.Schema.WidgetInstance.Axes do
  @moduledoc """
  Embed schema for Axes of widget.
  """

  use AcqdatCore.Schema

  embedded_schema do
    field(:name, :string)
    field(:source_type, :string)
    field(:source_details, :map)
  end

  @permitted ~w(name source_type source_details)a

  def changeset(%__MODULE__{} = axes, params) do
    axes
    |> cast(params, @permitted)
  end
end
