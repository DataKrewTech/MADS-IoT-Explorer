defmodule AcqdatCore.DashboardManagement.Schema.Panel do
  @moduledoc """
  Models a Dashboard's Panel Entity.

  Panels are used for grouping collection of widgets and providing them with a identifier.

  Any particular odashboard can have multiple panels.

  A Panel consists of multiple widgets.
  """
  use AcqdatCore.Schema
  alias AcqdatCore.Schema.EntityManagement.Organisation
  alias AcqdatCore.DashboardManagement.Schema.{Dashboard, WidgetInstance, CommandWidget}
  alias AcqdatCore.DashboardManagement.Schema.Panel.FilterMetadata

  @typedoc """
  `name`: Name of the panel, which will be unique with respective to dashboard.
  `uuid`: A universally unique id to identify the panel.
  `settings`: All the settings of panel
  """
  @type t :: %__MODULE__{}
  schema("acqdat_panel") do
    field(:name, :string, null: false)
    field(:description, :string)
    field(:uuid, :string, null: false)
    field(:slug, :string, null: false)
    field(:settings, :map)
    field(:widget_layouts, :map)

    # associations
    belongs_to(:org, Organisation, on_replace: :delete)
    belongs_to(:dashboard, Dashboard, on_replace: :delete)
    has_many(:widget_instances, WidgetInstance, on_replace: :delete)
    has_many(:command_widgets, CommandWidget)

    # embedded associations
    embeds_one(:filter_metadata, FilterMetadata, on_replace: :delete)

    timestamps(type: :utc_datetime)
  end

  @required_params ~w(uuid slug name org_id dashboard_id)a
  @optional_params ~w(settings description widget_layouts)a
  @permitted @optional_params ++ @required_params

  def changeset(%__MODULE__{} = panel, params) do
    panel
    |> cast(params, @permitted)
    |> add_slug()
    |> add_uuid()
    |> validate_required(@required_params)
    |> common_changeset()
  end

  def update_changeset(%__MODULE__{} = panel, params) do
    panel
    |> cast(params, @permitted)
    |> validate_required(@required_params)
    |> common_changeset()
  end

  @spec common_changeset(Ecto.Changeset.t()) :: Ecto.Changeset.t()
  def common_changeset(changeset) do
    changeset
    |> cast_embed(:filter_metadata, with: &FilterMetadata.changeset/2)
    |> assoc_constraint(:org)
    |> assoc_constraint(:dashboard)
    |> unique_constraint(:name,
      name: :unique_panel_name_per_dashboard,
      message: "unique panel name under dashboard"
    )
  end

  # TODO: Need to remove these codes, after fbp branch is merged to master
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

defmodule AcqdatCore.DashboardManagement.Schema.Panel.FilterMetadata do
  @moduledoc """
  Embed schema for filter_metadata related to panel.
  """

  use AcqdatCore.Schema

  embedded_schema do
    field(:from_date, :integer, default: DateTime.to_unix(DateTime.utc_now(), :millisecond))
    field(:to_date, :integer, default: DateTime.to_unix(DateTime.utc_now(), :millisecond))
    field(:aggregate_func, :string, default: "max")
    field(:group_interval, :integer, default: 1)
    field(:group_interval_type, :string, default: "hour")
    field(:last, :string, default: "30_day")
    field(:type, :string, default: "historical")
  end

  @permitted ~w(from_date to_date aggregate_func group_interval group_interval_type type last)a

  def changeset(%__MODULE__{} = settings, params) do
    settings
    |> cast(params, @permitted)
  end
end
