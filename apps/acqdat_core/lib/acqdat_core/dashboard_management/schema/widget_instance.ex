defmodule AcqdatCore.DashboardManagement.Schema.WidgetInstance do
  @moduledoc """
  WidgetInstance are instances of the class Widget, holding the same behaviour as that of widgets,
  but with different data-sources.

  It is used to model associations between dashboard and widget

  A widget_instance has four important properties along with others:
  - `visual_properties`
  - `widget_settings`
  - `series_data`

  **Visual Properties**
  Visual Properties hold the keys that can be set for the particular widget instance.
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
  alias AcqdatCore.DashboardManagement.Schema.{Panel, Dashboard}
  alias AcqdatCore.DashboardManagement.Schema.WidgetInstance.SeriesData

  @typedoc """
  `label`: widget_instance name
  `uuid`: unique number
  `visual_properties`: holds visualization related properties
  `widget_settings`: holds widget specific settings on the respective dashboard
  """

  @type t :: %__MODULE__{}

  schema("acqdat_widget_instance") do
    field(:label, :string, null: false)
    field(:slug, :string, null: false)
    field(:widget_settings, :map)
    field(:uuid, :string)
    field(:visual_properties, :map)

    # embedded associations
    embeds_many(:series_data, SeriesData, on_replace: :delete)

    # associations
    belongs_to(:widget, Widget, on_replace: :delete)
    belongs_to(:dashboard, Dashboard, on_replace: :delete)
    belongs_to(:panel, Panel, on_replace: :delete)

    timestamps(type: :utc_datetime)
  end

  @required ~w(label widget_id dashboard_id panel_id slug uuid)a
  @optional ~w(widget_settings visual_properties)a
  @permitted @required ++ @optional

  @spec changeset(
          __MODULE__.t(),
          map
        ) :: Ecto.Changeset.t()
  def changeset(%__MODULE__{} = widget_instance, params) do
    widget_instance
    |> cast(params, @permitted)
    |> add_slug()
    |> add_uuid()
    |> cast_embed(:series_data, with: &SeriesData.changeset/2)
    |> validate_required(@required)
    |> common_changeset()
  end

  def update_changeset(%__MODULE__{} = widget_instance, params) do
    widget_instance
    |> cast(params, @permitted)
    |> cast_embed(:series_data, with: &SeriesData.changeset/2)
    |> validate_required(@required)
    |> common_changeset()
  end

  @spec common_changeset(Ecto.Changeset.t()) :: Ecto.Changeset.t()
  defp common_changeset(changeset) do
    changeset
    |> assoc_constraint(:widget)
    |> assoc_constraint(:dashboard)
    |> assoc_constraint(:panel)
    |> unique_constraint(:label,
      name: :unique_widget_name_per_panel,
      message: "unique widget label under dashboard's panel"
    )
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
    field(:source_metadata, :map)
  end

  @permitted ~w(name source_type source_metadata)a

  def changeset(%__MODULE__{} = axes, params) do
    axes
    |> cast(params, @permitted)
  end
end
