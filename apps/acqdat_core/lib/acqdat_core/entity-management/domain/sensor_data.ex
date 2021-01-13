defmodule AcqdatCore.Domain.EntityManagement.SensorData do
  @moduledoc """
  The Module exposes helper functions to interact with sensordata model
  data.
  All advanced queries related to SensorData will be placed here.
  """
  import Ecto.Query
  alias AcqdatCore.Schema.EntityManagement.{SensorsData, Sensor}

  def filter_by_date_query(entity_id, date_from, date_to) when is_integer(entity_id) do
    from(
      data in SensorsData,
      where:
        data.sensor_id == ^entity_id and data.inserted_timestamp >= ^date_from and
          data.inserted_timestamp <= ^date_to
    )
  end

  def filter_by_date_query(entity_ids, date_from, date_to) when is_list(entity_ids) do
    from(
      data in SensorsData,
      where:
        data.sensor_id in ^entity_ids and data.inserted_timestamp >= ^date_from and
          data.inserted_timestamp <= ^date_to
    )
  end

  def filter_by_date_query_wrt_parent(entity_ids, date_from, date_to) when is_list(entity_ids) do
    from(
      data in SensorsData,
      join: sensor in Sensor,
      on:
        data.sensor_id == sensor.id and data.sensor_id in ^entity_ids and
          data.inserted_timestamp >= ^date_from and
          data.inserted_timestamp <= ^date_to,
      select_merge: %{sensor_parent_id: sensor.parent_id, sensor_name: sensor.name}
    )
  end

  def latest_group_by_date_query(
        subquery,
        param_uuid,
        aggregator,
        grp_interval,
        group_interval_type
      )
      when aggregator == "sum" and is_binary(param_uuid) do
    grp_int = grp_interval |> compute_grp_interval(group_interval_type)

    from(
      data in subquery,
      cross_join: c in fragment("unnest(?)", data.parameters),
      where: fragment("?->>'uuid'=?", c, ^param_uuid),
      group_by: fragment("date_filt"),
      order_by: ^[desc: dynamic([d], fragment("date_filt"))],
      limit: 1,
      select: %{
        x:
          fragment(
            "EXTRACT(EPOCH FROM (time_bucket(?::VARCHAR::INTERVAL, ?)))*1000 as date_filt",
            ^grp_int,
            data.inserted_timestamp
          ),
        y: fragment("sum(CAST(ROUND(CAST (?->>'value' AS NUMERIC), 2) AS FLOAT))", c)
      }
    )
  end

  def latest_group_by_date_query(
        subquery,
        param_uuids,
        aggregator,
        grp_interval,
        group_interval_type,
        limit_elem
      )
      when aggregator == "max" and is_list(param_uuids) do
    grp_int = grp_interval |> compute_grp_interval(group_interval_type)

    from(
      data in subquery,
      cross_join: c in fragment("unnest(?)", data.parameters),
      where: fragment("?->>'uuid'", c) in ^param_uuids,
      group_by: [data.sensor_id, fragment("date_filt")],
      order_by: ^[desc: dynamic([d], fragment("date_filt"))],
      limit: ^limit_elem,
      select: %{
        time:
          fragment(
            "EXTRACT(EPOCH FROM (time_bucket(?::VARCHAR::INTERVAL, ?)))*1000 as date_filt",
            ^grp_int,
            data.inserted_timestamp
          ),
        id: data.sensor_id,
        value: fragment("max(CAST(ROUND(CAST (?->>'value' AS NUMERIC), 2) AS FLOAT))", c)
      }
    )
  end

  def latest_group_by_date_query(
        subquery,
        param_uuids,
        aggregator,
        grp_interval,
        group_interval_type,
        limit_elem
      )
      when aggregator == "min" and is_list(param_uuids) do
    grp_int = grp_interval |> compute_grp_interval(group_interval_type)

    from(
      data in subquery,
      cross_join: c in fragment("unnest(?)", data.parameters),
      where: fragment("?->>'uuid'", c) in ^param_uuids,
      group_by: [data.sensor_id, fragment("date_filt")],
      order_by: ^[desc: dynamic([d], fragment("date_filt"))],
      limit: ^limit_elem,
      select: %{
        time:
          fragment(
            "EXTRACT(EPOCH FROM (time_bucket(?::VARCHAR::INTERVAL, ?)))*1000 as date_filt",
            ^grp_int,
            data.inserted_timestamp
          ),
        id: data.sensor_id,
        value: fragment("min(CAST(ROUND(CAST (?->>'value' AS NUMERIC), 2) AS FLOAT))", c)
      }
    )
  end

  def latest_group_by_date_query(
        subquery,
        param_uuids,
        aggregator,
        grp_interval,
        group_interval_type,
        limit_elem
      )
      when aggregator == "sum" and is_list(param_uuids) do
    grp_int = grp_interval |> compute_grp_interval(group_interval_type)

    from(
      data in subquery,
      cross_join: c in fragment("unnest(?)", data.parameters),
      where: fragment("?->>'uuid'", c) in ^param_uuids,
      group_by: [data.sensor_id, fragment("date_filt")],
      order_by: ^[desc: dynamic([d], fragment("date_filt"))],
      limit: ^limit_elem,
      select: %{
        time:
          fragment(
            "EXTRACT(EPOCH FROM (time_bucket(?::VARCHAR::INTERVAL, ?)))*1000 as date_filt",
            ^grp_int,
            data.inserted_timestamp
          ),
        id: data.sensor_id,
        value: fragment("sum(CAST(ROUND(CAST (?->>'value' AS NUMERIC), 2) AS FLOAT))", c)
      }
    )
  end

  def latest_group_by_date_query(
        subquery,
        param_uuids,
        aggregator,
        grp_interval,
        group_interval_type,
        limit_elem
      )
      when aggregator == "count" and is_list(param_uuids) do
    grp_int = grp_interval |> compute_grp_interval(group_interval_type)

    from(
      data in subquery,
      cross_join: c in fragment("unnest(?)", data.parameters),
      where: fragment("?->>'uuid'", c) in ^param_uuids,
      group_by: [data.sensor_id, fragment("date_filt")],
      order_by: ^[desc: dynamic([d], fragment("date_filt"))],
      limit: ^limit_elem,
      select: %{
        time:
          fragment(
            "EXTRACT(EPOCH FROM (time_bucket(?::VARCHAR::INTERVAL, ?)))*1000 as date_filt",
            ^grp_int,
            data.inserted_timestamp
          ),
        id: data.sensor_id,
        value: fragment("count(CAST(ROUND(CAST (?->>'value' AS NUMERIC), 2) AS FLOAT))", c)
      }
    )
  end

  def latest_group_by_date_query(
        subquery,
        param_uuids,
        aggregator,
        grp_interval,
        group_interval_type,
        limit_elem
      )
      when aggregator == "average" and is_list(param_uuids) do
    grp_int = grp_interval |> compute_grp_interval(group_interval_type)

    from(
      data in subquery,
      cross_join: c in fragment("unnest(?)", data.parameters),
      where: fragment("?->>'uuid'", c) in ^param_uuids,
      group_by: [data.sensor_id, fragment("date_filt")],
      order_by: ^[desc: dynamic([d], fragment("date_filt"))],
      limit: ^limit_elem,
      select: %{
        time:
          fragment(
            "EXTRACT(EPOCH FROM (time_bucket(?::VARCHAR::INTERVAL, ?)))*1000 as date_filt",
            ^grp_int,
            data.inserted_timestamp
          ),
        id: data.sensor_id,
        value: fragment("avg(CAST(ROUND(CAST (?->>'value' AS NUMERIC), 2) AS FLOAT))", c)
      }
    )
  end

  def latest_group_by_date_query(
        subquery,
        param_uuid,
        aggregator,
        grp_interval,
        group_interval_type
      )
      when aggregator == "max" and is_binary(param_uuid) do
    grp_int = grp_interval |> compute_grp_interval(group_interval_type)

    from(
      data in subquery,
      cross_join: c in fragment("unnest(?)", data.parameters),
      where: fragment("?->>'uuid'=?", c, ^param_uuid),
      group_by: fragment("date_filt"),
      order_by: ^[desc: dynamic([d], fragment("date_filt"))],
      limit: 1,
      select: %{
        x:
          fragment(
            "EXTRACT(EPOCH FROM (time_bucket(?::VARCHAR::INTERVAL, ?)))*1000 as date_filt",
            ^grp_int,
            data.inserted_timestamp
          ),
        y: fragment("max(CAST(ROUND(CAST (?->>'value' AS NUMERIC), 2) AS FLOAT))", c)
      }
    )
  end

  def latest_group_by_date_query(
        subquery,
        param_uuid,
        aggregator,
        grp_interval,
        group_interval_type
      )
      when aggregator == "min" and is_binary(param_uuid) do
    grp_int = grp_interval |> compute_grp_interval(group_interval_type)

    from(
      data in subquery,
      cross_join: c in fragment("unnest(?)", data.parameters),
      where: fragment("?->>'uuid'=?", c, ^param_uuid),
      group_by: fragment("date_filt"),
      order_by: ^[desc: dynamic([d], fragment("date_filt"))],
      limit: 1,
      select: %{
        x:
          fragment(
            "EXTRACT(EPOCH FROM (time_bucket(?::VARCHAR::INTERVAL, ?)))*1000 as date_filt",
            ^grp_int,
            data.inserted_timestamp
          ),
        y: fragment("min(CAST(ROUND(CAST (?->>'value' AS NUMERIC), 2) AS FLOAT))", c)
      }
    )
  end

  def latest_group_by_date_query(
        subquery,
        param_uuid,
        aggregator,
        grp_interval,
        group_interval_type
      )
      when aggregator == "count" and is_binary(param_uuid) do
    grp_int = grp_interval |> compute_grp_interval(group_interval_type)

    from(
      data in subquery,
      cross_join: c in fragment("unnest(?)", data.parameters),
      where: fragment("?->>'uuid'=?", c, ^param_uuid),
      group_by: fragment("date_filt"),
      order_by: ^[desc: dynamic([d], fragment("date_filt"))],
      limit: 1,
      select: %{
        x:
          fragment(
            "EXTRACT(EPOCH FROM (time_bucket(?::VARCHAR::INTERVAL, ?)))*1000 as date_filt",
            ^grp_int,
            data.inserted_timestamp
          ),
        y: fragment("count(CAST(ROUND(CAST (?->>'value' AS NUMERIC), 2) AS FLOAT))", c)
      }
    )
  end

  def latest_group_by_date_query(
        subquery,
        param_uuid,
        aggregator,
        grp_interval,
        group_interval_type
      )
      when aggregator == "average" and is_binary(param_uuid) do
    grp_int = grp_interval |> compute_grp_interval(group_interval_type)

    from(
      data in subquery,
      cross_join: c in fragment("unnest(?)", data.parameters),
      where: fragment("?->>'uuid'=?", c, ^param_uuid),
      group_by: fragment("date_filt"),
      order_by: ^[desc: dynamic([d], fragment("date_filt"))],
      limit: 1,
      select: %{
        x:
          fragment(
            "EXTRACT(EPOCH FROM (time_bucket(?::VARCHAR::INTERVAL, ?)))*1000 as date_filt",
            ^grp_int,
            data.inserted_timestamp
          ),
        y: fragment("avg(CAST(ROUND(CAST (?->>'value' AS NUMERIC), 2) AS FLOAT))", c)
      }
    )
  end

  def group_by_date_query(subquery, param_uuid, aggregator, grp_interval, group_interval_type)
      when aggregator == "min" do
    grp_int = grp_interval |> compute_grp_interval(group_interval_type)

    from(
      data in subquery,
      cross_join: c in fragment("unnest(?)", data.parameters),
      where: fragment("?->>'uuid'=?", c, ^param_uuid),
      group_by: fragment("date_filt"),
      order_by: fragment("date_filt"),
      select: [
        fragment(
          "EXTRACT(EPOCH FROM (time_bucket(?::VARCHAR::INTERVAL, ?)))*1000 as date_filt",
          ^grp_int,
          data.inserted_timestamp
        ),
        fragment("min(CAST(ROUND(CAST (?->>'value' AS NUMERIC), 2) AS FLOAT))", c)
      ]
    )
  end

  def group_by_date_query(subquery, param_uuid, aggregator, grp_interval, group_interval_type)
      when aggregator == "max" do
    grp_int = grp_interval |> compute_grp_interval(group_interval_type)

    from(
      data in subquery,
      cross_join: c in fragment("unnest(?)", data.parameters),
      where: fragment("?->>'uuid'=?", c, ^param_uuid),
      group_by: fragment("date_filt"),
      order_by: fragment("date_filt"),
      select: [
        fragment(
          "EXTRACT(EPOCH FROM (time_bucket(?::VARCHAR::INTERVAL, ?)))*1000 as date_filt",
          ^grp_int,
          data.inserted_timestamp
        ),
        fragment("max(CAST(ROUND(CAST (?->>'value' AS NUMERIC), 2) AS FLOAT))", c)
      ]
    )
  end

  def group_by_date_query(subquery, param_uuid, aggregator, grp_interval, group_interval_type)
      when aggregator == "sum" do
    grp_int = grp_interval |> compute_grp_interval(group_interval_type)

    from(
      data in subquery,
      cross_join: c in fragment("unnest(?)", data.parameters),
      where: fragment("?->>'uuid'=?", c, ^param_uuid),
      group_by: fragment("date_filt"),
      order_by: fragment("date_filt"),
      select: [
        fragment(
          "EXTRACT(EPOCH FROM (time_bucket(?::VARCHAR::INTERVAL, ?)))*1000 as date_filt",
          ^grp_int,
          data.inserted_timestamp
        ),
        fragment("sum(CAST(ROUND(CAST (?->>'value' AS NUMERIC), 2) AS FLOAT))", c)
      ]
    )
  end

  def group_by_date_query(subquery, param_uuid, aggregator, grp_interval, group_interval_type)
      when aggregator == "count" do
    grp_int = grp_interval |> compute_grp_interval(group_interval_type)

    from(
      data in subquery,
      cross_join: c in fragment("unnest(?)", data.parameters),
      where: fragment("?->>'uuid'=?", c, ^param_uuid),
      group_by: fragment("date_filt"),
      order_by: fragment("date_filt"),
      select: [
        fragment(
          "EXTRACT(EPOCH FROM (time_bucket(?::VARCHAR::INTERVAL, ?)))*1000 as date_filt",
          ^grp_int,
          data.inserted_timestamp
        ),
        fragment("count(CAST(ROUND(CAST (?->>'value' AS NUMERIC), 2) AS FLOAT))", c)
      ]
    )
  end

  def group_by_date_query(subquery, param_uuid, aggregator, grp_interval, group_interval_type)
      when aggregator == "average" do
    grp_int = grp_interval |> compute_grp_interval(group_interval_type)

    from(
      data in subquery,
      cross_join: c in fragment("unnest(?)", data.parameters),
      where: fragment("?->>'uuid'=?", c, ^param_uuid),
      group_by: fragment("date_filt"),
      order_by: fragment("date_filt"),
      select: [
        fragment(
          "EXTRACT(EPOCH FROM (time_bucket(?::VARCHAR::INTERVAL, ?)))*1000 as date_filt",
          ^grp_int,
          data.inserted_timestamp
        ),
        fragment("avg(CAST(ROUND(CAST (?->>'value' AS NUMERIC), 2) AS FLOAT))", c)
      ]
    )
  end

  def fetch_sensors_data(
        subquery,
        param_uuids
      ) do
    from(
      data in subquery(subquery),
      cross_join: c in fragment("unnest(?)", data.parameters),
      where: fragment("?->>'name'", c) in ^param_uuids,
      select: %{
        parent_id: data.sensor_parent_id,
        time: data.inserted_timestamp,
        id: data.sensor_id,
        name: data.sensor_name,
        value: fragment("?->>'value'", c),
        param_name: fragment("?->>'name'", c)
      }
    )
  end

  def compute_grp_interval(grp_interval, group_interval_type) do
    if group_interval_type == "month" do
      "#{4 * String.to_integer(grp_interval)} week"
    else
      "#{grp_interval} #{group_interval_type}"
    end
  end
end
