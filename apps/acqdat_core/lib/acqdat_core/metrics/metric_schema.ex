defmodule AcqdatCore.Schema.Metrics do
  use AcqdatCore.Schema
  alias AcqdatCore.Schema.Metrics.Meta

  @type t :: %__MODULE__{
    inserted_time: DateTime.t(),
    metrics: map()
  }

  schema "acqdat_metrics" do
    field(:inserted_time, :utc_datetime)
    embeds_one(:metrics, Meta)

    timestamps(type: :utc_datetime, updated_at: false)
  end

  def changeset(%__MODULE__{} = metric, params) do
    metric
    |> cast(params, [:inserted_time, :metrics])
    |> cast_embed(:metrics)
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

  def changeset() do

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
end

defmodule AcqdatCore.Schema.Metrics.DashboardMeta do
  use AcqdatCore.Schema

  embedded_schema do
    field(:dashboards, :map)
    field(:panels, :map)
    field(:widgets, :map)
  end
end

defmodule AcqdatCore.Schema.Metrics.DataInsightsMeta do
  use AcqdatCore.Schema

  embedded_schema do
    field(:fact_tables, :map)
    field(:visualisations, :map)
  end

end

defmodule AcqdatCore.Schema.Metrics.RoleManagerMeta do
  use AcqdatCore.Schema

  embedded_schema do
    field(:users, :map)
  end
end
