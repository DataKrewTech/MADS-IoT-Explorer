defmodule AcqdatCore.Schema.Metrics do
  use AcqdatCore.Schema
  alias AcqdatCore.Schema.Metrics.Meta

  @type t :: %__MODULE__{
          inserted_time: DateTime.t(),
          org_id: integer(),
          metrics: map()
        }

  schema "acqdat_metrics" do
    field(:inserted_time, :utc_datetime, null: false)
    field(:org_id, :integer, null: false)
    embeds_one(:metrics, Meta)

    timestamps(type: :utc_datetime)
  end

  def changeset(%__MODULE__{} = metric, params) do
    metric
    |> cast(params, [:inserted_time, :org_id])
    |> cast_embed(:metrics, with: &Meta.changeset/2)
    |> validate_required([:inserted_time, :org_id])
  end
end

defmodule AcqdatCore.Schema.Metrics.Meta do
  alias AcqdatCore.Schema.Metrics.EntityMeta
  alias AcqdatCore.Schema.Metrics.DashboardMeta
  alias AcqdatCore.Schema.Metrics.DataInsightsMeta
  alias AcqdatCore.Schema.Metrics.RoleManagerMeta

  use AcqdatCore.Schema

  embedded_schema do
    embeds_one(:entities, EntityMeta)
    embeds_one(:dashboards, DashboardMeta)
    embeds_one(:data_insights, DataInsightsMeta)
    embeds_one(:role_manager, RoleManagerMeta)
  end

  @spec changeset(any, any) :: none
  def changeset(meta, params) do
    meta
    |> cast(params, [])
    |> cast_embed(:entities, with: &EntityMeta.changeset/2)
    |> cast_embed(:dashboards, with: &DashboardMeta.changeset/2)
    |> cast_embed(:data_insights, with: &DataInsightsMeta.changeset/2)
    |> cast_embed(:role_manager, with: &RoleManagerMeta.changeset/2)
  end
end

defmodule AcqdatCore.Schema.Metrics.EntityMeta do
  use AcqdatCore.Schema

  embedded_schema do
    field(:sensors, :map)
    field(:sensor_types, :map)
    field(:assets, :map)
    field(:asset_types, :map)
    field(:projects, :map)
    field(:gateways, :map)
    field(:active_parameters, :map)
  end

  @optional_params ~w(sensors sensor_types assets asset_types projects gateways active_parameters)a

  def changeset(entitymeta, params) do
    entitymeta
    |> cast(params, @optional_params)
  end
end

defmodule AcqdatCore.Schema.Metrics.DashboardMeta do
  use AcqdatCore.Schema

  embedded_schema do
    field(:dashboards, :map)
    field(:panels, :map)
    field(:widgets, :map)
  end

  @optional_params ~w(dashboards panels widgets)a

  def changeset(dashboardmeta, params) do
    dashboardmeta
    |> cast(params, @optional_params)
  end
end

defmodule AcqdatCore.Schema.Metrics.DataInsightsMeta do
  use AcqdatCore.Schema

  embedded_schema do
    field(:fact_tables, :map)
    field(:visualisations, :map)
  end

  @optional_params ~w(fact_tables visualisations)a

  def changeset(datainsightsmeta, params) do
    datainsightsmeta
    |> cast(params, @optional_params)
  end
end

defmodule AcqdatCore.Schema.Metrics.RoleManagerMeta do
  use AcqdatCore.Schema

  embedded_schema do
    field(:users, :map)
  end

  @optional_params ~w(users)a

  def changeset(rolemanagermeta, params) do
    rolemanagermeta
    |> cast(params, @optional_params)
  end
end
