defmodule AcqdatCore.DataInsights.Schema.FactTables do
  @moduledoc """

  Fact Tables are used for representing data in tablular or 2D format.
  Using Fact Table, we can create multiple pivot tables,
  and these pivot table is used for visually repersenting our data

  A FactTable has four important properties along with others:
  - `name`
  - `columns_metadata`
  - `data_range(from_date, to_date)`
  - `grouping metadata(group_interval, group_interval_type)`
  """

  use AcqdatCore.Schema
  alias AcqdatCore.Schema.EntityManagement.{Organisation, Project}
  alias AcqdatCore.DataInsights.Schema.Visualizations
  alias AcqdatCore.Schema.RoleManagement.User

  @typedoc """
  `name`: Fact Table name
  `uuid`: unique number
  `columns_metadata`: holds columns metadata
  `from_date`: holds starting datetime of date range
  `to_date`: holds ending datetime of date range
  `group_interval`: holds group_interval of grouping metdata like 1, 15
  `group_interval_type`: holds group_interval_type of grouping metdata like hour, day, week, month, year
  """

  @type t :: %__MODULE__{}

  schema("acqdat_fact_tables") do
    field(:name, :string, null: false)
    field(:slug, :string, null: false)
    field(:uuid, :string, null: false)
    field(:columns_metadata, {:array, :map}, default: [])
    field(:date_range_settings, :map)
    field(:from_date, :utc_datetime, default: DateTime.truncate(DateTime.utc_now(), :second))
    field(:to_date, :utc_datetime, default: DateTime.truncate(DateTime.utc_now(), :second))
    field(:group_interval, :integer)
    field(:group_interval_type, :string)

    # virtual field, to load total pivot_tables count per fact_table
    field(:pivot_count, :integer, virtual: true)

    # associations
    belongs_to(:project, Project, on_replace: :delete)
    belongs_to(:org, Organisation, on_replace: :delete)
    belongs_to(:creator, User, on_replace: :raise)
    has_many(:pivot_tables, Visualizations, foreign_key: :fact_table_id)

    timestamps(type: :utc_datetime)
  end

  @required ~w(name project_id org_id creator_id slug uuid)a
  @optional ~w(group_interval group_interval_type columns_metadata date_range_settings)a
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
    |> validate_required(@required)
    |> common_changeset()
  end

  def update_changeset(%__MODULE__{} = view, params) do
    view
    |> cast(params, @permitted)
    |> validate_required(@required)
    |> common_changeset()
  end

  @spec common_changeset(Ecto.Changeset.t()) :: Ecto.Changeset.t()
  defp common_changeset(changeset) do
    changeset
    |> assoc_constraint(:project)
    |> assoc_constraint(:org)
    |> assoc_constraint(:creator)
    |> unique_constraint(:name,
      name: :unique_fact_table_name_per_project,
      message: "unique fact table name under a project"
    )
  end
end
