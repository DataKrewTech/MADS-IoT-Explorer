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

  def filter_by_date_query_wrt_format(entity_ids, date_from, date_to) when is_list(entity_ids) do
    from(
      data in SensorsData,
      where:
        data.sensor_id in ^entity_ids and data.inserted_timestamp >= ^date_from and
          data.inserted_timestamp <= ^date_to,
      group_by: data.inserted_timestamp,
      select: [
        data.inserted_timestamp,
        fragment("array_agg((sensor_id, parameters))")
      ],
      order_by: [asc: data.inserted_timestamp]
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
      when aggregator == "no" and is_binary(param_uuid) do
    from(
      data in subquery,
      cross_join: c in fragment("unnest(?)", data.parameters),
      where: fragment("?->>'uuid'=?", c, ^param_uuid),
      order_by: [asc: data.inserted_timestamp],
      limit: 1,
      select: %{
        x: fragment("EXTRACT(EPOCH FROM ?)*1000", data.inserted_timestamp),
        y: fragment("CAST(ROUND(CAST (?->>'value' AS NUMERIC), 2) AS FLOAT)", c)
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
      when aggregator == "no" and is_list(param_uuids) do
    from(
      data in subquery,
      cross_join: c in fragment("unnest(?)", data.parameters),
      where: fragment("?->>'uuid'=?", c, ^param_uuids),
      group_by: [data.sensor_id, data.inserted_timestamp],
      order_by: [asc: data.inserted_timestamp],
      limit: ^limit_elem,
      select: %{
        time: fragment("EXTRACT(EPOCH FROM ?)*1000", data.inserted_timestamp),
        id: data.sensor_id,
        value: fragment("CAST(ROUND(CAST (?->>'value' AS NUMERIC), 2) AS FLOAT)", c)
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
      when aggregator == "no" do
    from(
      data in subquery,
      cross_join: c in fragment("unnest(?)", data.parameters),
      where: fragment("?->>'uuid'=?", c, ^param_uuid),
      order_by: [asc: data.inserted_timestamp],
      select: [
        fragment("EXTRACT(EPOCH FROM ?)*1000", data.inserted_timestamp),
        fragment("CAST(ROUND(CAST (?->>'value' AS NUMERIC), 2) AS FLOAT)", c)
      ]
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

  def fetch_sensors_data_with_parent_id(
        subquery,
        param_uuids
      ) do
    from(
      data in subquery(subquery),
      cross_join: c in fragment("unnest(?)", data.parameters),
      where: fragment("?->>'uuid'", c) in ^param_uuids,
      select: %{
        parent_id: data.sensor_parent_id,
        time: data.inserted_timestamp,
        id: data.sensor_id,
        name: data.sensor_name,
        value: fragment("?->>'value'", c),
        param_name: fragment("?->>'name'", c),
        param_uuid: fragment("?->>'uuid'", c)
      }
    )
  end

  def fetch_sensors_data(subquery, param_uuids) do
    from(
      data in subquery(subquery),
      cross_join: c in fragment("unnest(?)", data.parameters),
      where: fragment("?->>'uuid'", c) in ^param_uuids,
      select: %{
        time: data.inserted_timestamp,
        id: data.sensor_id,
        name: data.sensor_name,
        value: fragment("?->>'value'", c),
        param_name: fragment("?->>'name'", c),
        param_uuid: fragment("?->>'uuid'", c)
      }
    )
  end

  def fetch_sensor_data_btw_time_intv(sensor_ids, date_from, date_to) do
    from(
      data in SensorsData,
      join: sensor in Sensor,
      on:
        data.sensor_id == sensor.id and data.sensor_id in ^sensor_ids and
          data.inserted_timestamp >= ^date_from and
          data.inserted_timestamp <= ^date_to,
      select_merge: %{sensor_name: sensor.name}
    )
  end

  def fetch_sensors_values_n_timeseries(
        subquery,
        param_uuids
      ) do
    from(
      data in subquery(subquery),
      cross_join: c in fragment("unnest(?)", data.parameters),
      where: fragment("?->>'uuid'", c) in ^param_uuids,
      select: [
        fragment("?->>'value'", c),
        data.inserted_timestamp
      ]
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
