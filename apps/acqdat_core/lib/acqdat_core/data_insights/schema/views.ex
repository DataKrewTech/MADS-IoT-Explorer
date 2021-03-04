defmodule AcqdatCore.DataInsights.Schema.Views do
  @moduledoc """
  Views are used for visually representing widget to user.
  They are instances of the class Widget, holding the same behaviour as that of widgets,
  but with different data-sources and using this we can perform analysis on data.

  It is used to model associations between dashboard's panel and widget

  A view has four important properties along with others:
  - `visual_properties`
  - `data_properties`
  - `filter_metadata`

  **Visual Properties**
  Visual Properties hold the keys that can be set for the particular widget instance.
  The keys are defined by module for a particular vendor the information
  is derived from widget_type to which the widget belongs.

  **Data Properties*
  It holds mapping of all the series's axes and its associated datasources.
  Each and every axes will be associated with it respective datasource.
  """

  use AcqdatCore.Schema
  alias AcqdatCore.Widgets.Schema.Widget
  alias AcqdatCore.Schema.EntityManagement.Organisation
  alias AcqdatCore.DataInsights.Schema.Views.FilterMetadata

  @typedoc """
  `name`: view name
  `uuid`: unique number
  `visual_properties`: holds visualization related properties
  `data_properties`: holds data related properties
  `filter_metadata`: holds filter params
  """

  @view_type ~w(Card Table Bar Line Pie Scatter HeatMap)s

  @type t :: %__MODULE__{}

  schema("acqdat_views") do
    field(:name, :string, null: false)
    field(:slug, :string, null: false)
    field(:uuid, :string, null: false)
    field(:type, :string, null: false)
    field(:visual_properties, :map)
    field(:data_properties, :map)

    # embedded associations
    embeds_one(:filter_metadata, FilterMetadata, on_replace: :delete)

    # associations
    belongs_to(:widget, Widget, on_replace: :delete)
    belongs_to(:org, Organisation, on_replace: :delete)

    timestamps(type: :utc_datetime)
  end

  @required ~w(name widget_id org_id slug uuid type)a
  @optional ~w(data_properties visual_properties)a
  @permitted @required ++ @optional

  @spec changeset(
          __MODULE__.t(),
          map
        ) :: Ecto.Changeset.t()
  def changeset(%__MODULE__{} = view, params) do
    view
    |> cast(params, @permitted)
    |> add_slug()
    |> add_uuid()
    |> cast_embed(:filter_metadata, with: &FilterMetadata.changeset/2)
    |> validate_required(@required)
    |> common_changeset()
  end

  def update_changeset(%__MODULE__{} = view, params) do
    view
    |> cast(params, @permitted)
    |> cast_embed(:filter_metadata, with: &FilterMetadata.changeset/2)
    |> validate_required(@required)
    |> common_changeset()
  end

  @spec common_changeset(Ecto.Changeset.t()) :: Ecto.Changeset.t()
  defp common_changeset(changeset) do
    changeset
    |> assoc_constraint(:widget)
    |> assoc_constraint(:org)
    |> validate_inclusion(:type, @view_type)
    |> unique_constraint(:name,
      name: :unique_view_name_per_org,
      message: "unique view name under organisation"
    )
  end
end

defmodule AcqdatCore.DataInsights.Schema.Views.FilterMetadata do
  @moduledoc """
  Embed schema for filter_metadata related to views.
  """

  use AcqdatCore.Schema

  embedded_schema do
    field(:from_date, :integer, default: DateTime.to_unix(DateTime.utc_now(), :millisecond))
    field(:to_date, :integer, default: DateTime.to_unix(DateTime.utc_now(), :millisecond))
    field(:group_interval, :integer, default: 1)
    field(:group_interval_type, :string, default: "hour")
    field(:order_by, :string, default: "asc")
    field(:order_column, :string)
  end

  @permitted ~w(from_date to_date group_interval group_interval_type order_by order_column)a

  def changeset(%__MODULE__{} = settings, params) do
    settings
    |> cast(params, @permitted)
  end
end
