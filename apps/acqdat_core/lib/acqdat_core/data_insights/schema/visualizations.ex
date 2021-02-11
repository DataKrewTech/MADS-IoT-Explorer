defmodule AcqdatCore.DataInsights.Schema.Visualizations do
  @moduledoc """

  Visualizations are used for representing cosolidated or accumulative data in visual/widget forms after grouping.
  Visualizations is child of FactTable

  A Pivot has four important properties along with others:
  - `name`
  - `filters`
  - `columns`
  - `rows`
  - `values`
  """

  use AcqdatCore.Schema
  alias AcqdatCore.Schema.EntityManagement.{Organisation, Project}
  alias AcqdatCore.DataInsights.Schema.FactTables
  alias AcqdatCore.Schema.RoleManagement.User

  @typedoc """
  `name`: Visualizations name
  `uuid`: unique number
  `filters`: holds filters metadata
  `columns`: holds columns metadata
  `rows`: holds rows metadata
  `values`: holds values metadata
  """

  @type t :: %__MODULE__{}

  schema("acqdat_visualizations") do
    field(:name, :string, null: false)
    field(:slug, :string, null: false)
    field(:uuid, :string, null: false)
    field(:filters, {:array, :map}, default: [])
    field(:columns, {:array, :map}, default: [])
    field(:rows, {:array, :map}, default: [])
    field(:values, {:array, :map}, default: [])

    # associations
    belongs_to(:project, Project, on_replace: :delete)
    belongs_to(:fact_table, FactTables, on_replace: :delete)
    belongs_to(:org, Organisation, on_replace: :delete)
    belongs_to(:creator, User, on_replace: :raise)

    timestamps(type: :utc_datetime)
  end

  @required ~w(name project_id fact_table_id creator_id org_id slug uuid)a
  @optional ~w(filters columns rows values)a
  @permitted @required ++ @optional

  @spec changeset(
          __MODULE__.t(),
          map
        ) :: Ecto.Changeset.t()
  def changeset(%__MODULE__{} = pivot_table, params) do
    pivot_table
    |> cast(params, @permitted)
    |> add_slug()
    |> add_uuid()
    |> validate_required(@required)
    |> common_changeset()
  end

  def update_changeset(%__MODULE__{} = pivot_table, params) do
    pivot_table
    |> cast(params, @permitted)
    |> validate_required(@required)
    |> common_changeset()
  end

  @spec common_changeset(Ecto.Changeset.t()) :: Ecto.Changeset.t()
  defp common_changeset(changeset) do
    changeset
    |> assoc_constraint(:org)
    |> assoc_constraint(:project)
    |> assoc_constraint(:creator)
    |> assoc_constraint(:fact_table)
    |> unique_constraint(:name,
      name: :unique_pivot_table_name_per_fact_table,
      message: "should have unique pivot table name per fact table"
    )
  end
end
