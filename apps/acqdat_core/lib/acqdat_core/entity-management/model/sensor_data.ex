defmodule AcqdatCore.Model.EntityManagement.SensorData do
  @moduledoc """
  The Module exposes helper functions to interact with sensor
  data.
  """
  import Ecto.Query
  alias AcqdatCore.Schema.EntityManagement.SensorsData
  alias AcqdatCore.Repo

  @doc """
  Returns `query` for getting sensor data by `start_time` and `end_time`.
  """

  # TODO:: Need to add all the read queries from timescale, as per the future requirements
  # def get_by_time_range(start_time, end_time) do
  #   from(
  #     data in SensorData,
  #     where: data.inserted_at >= ^start_time and data.inserted_at <= ^end_time,
  #     preload: [sensor: :device]
  #   )
  # end

  # def time_data_by_sensor(start_time, end_time, sensor_id) do
  #   query =
  #     from(
  #       data in SensorData,
  #       where:
  #         data.inserted_at >= ^start_time and data.inserted_at <= ^end_time and
  #           data.sensor_id == ^sensor_id,
  #       select: data
  #     )

  #   Repo.all(query)
  # end

  def create(params) do
    changeset = SensorsData.changeset(%SensorsData{}, params)
    Repo.insert(changeset)
  end

  # TODO: Needs to refactor code so that it will query on dynamic axes
  def get_all_by_parameters(entity_id, param_uuid, %{
        from_date: date_from,
        to_date: date_to,
        aggregate_func: aggregate_func,
        group_interval: group_interval
      }) do
    subquery = filter_by_date_query(entity_id, param_uuid, date_from, date_to)
    query = group_by_date_query(subquery, param_uuid, aggregate_func, group_interval)
    Repo.all(query)
  end

  def get_latest_by_parameters(entity_id, param_uuid, %{
        from_date: date_from,
        to_date: date_to,
        aggregate_func: aggregate_func,
        group_interval: group_interval
      }) do
    subquery = filter_by_date_query(entity_id, param_uuid, date_from, date_to)
    query = latest_group_by_date_query(subquery, param_uuid, aggregate_func, group_interval)
    Repo.one(query)
  end

  defp filter_by_date_query(entity_id, param_uuid, date_from, date_to) do
    from(
      data in SensorsData,
      where:
        data.sensor_id == ^entity_id and data.inserted_timestamp >= ^date_from and
          data.inserted_timestamp <= ^date_to
    )
  end

  defp latest_group_by_date_query(subquery, param_uuid, aggregator, grp_interval)
       when aggregator == "sum" do
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
            "EXTRACT(EPOCH FROM (date_trunc(?, ?)))*1000 as date_filt",
            ^grp_interval,
            data.inserted_timestamp
          ),
        y: fragment("sum(CAST(ROUND(CAST (?->>'value' AS NUMERIC), 2) AS FLOAT))", c)
      }
    )
  end

  defp latest_group_by_date_query(subquery, param_uuid, aggregator, grp_interval)
       when aggregator == "max" do
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
            "EXTRACT(EPOCH FROM (date_trunc(?, ?)))*1000 as date_filt",
            ^grp_interval,
            data.inserted_timestamp
          ),
        y: fragment("max(CAST(ROUND(CAST (?->>'value' AS NUMERIC), 2) AS FLOAT))", c)
      }
    )
  end

  defp latest_group_by_date_query(subquery, param_uuid, aggregator, grp_interval)
       when aggregator == "min" do
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
            "EXTRACT(EPOCH FROM (date_trunc(?, ?)))*1000 as date_filt",
            ^grp_interval,
            data.inserted_timestamp
          ),
        y: fragment("min(CAST(ROUND(CAST (?->>'value' AS NUMERIC), 2) AS FLOAT))", c)
      }
    )
  end

  defp latest_group_by_date_query(subquery, param_uuid, aggregator, grp_interval)
       when aggregator == "count" do
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
            "EXTRACT(EPOCH FROM (date_trunc(?, ?)))*1000 as date_filt",
            ^grp_interval,
            data.inserted_timestamp
          ),
        y: fragment("count(CAST(ROUND(CAST (?->>'value' AS NUMERIC), 2) AS FLOAT))", c)
      }
    )
  end

  defp latest_group_by_date_query(subquery, param_uuid, aggregator, grp_interval)
       when aggregator == "average" do
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
            "EXTRACT(EPOCH FROM (date_trunc(?, ?)))*1000 as date_filt",
            ^grp_interval,
            data.inserted_timestamp
          ),
        y: fragment("avg(CAST(ROUND(CAST (?->>'value' AS NUMERIC), 2) AS FLOAT))", c)
      }
    )
  end

  defp group_by_date_query(subquery, param_uuid, aggregator, grp_interval)
       when aggregator == "min" do
    from(
      data in subquery,
      cross_join: c in fragment("unnest(?)", data.parameters),
      where: fragment("?->>'uuid'=?", c, ^param_uuid),
      group_by: fragment("date_filt"),
      order_by: fragment("date_filt"),
      select: [
        fragment(
          "EXTRACT(EPOCH FROM (date_trunc(?, ?)))*1000 as date_filt",
          ^grp_interval,
          data.inserted_timestamp
        ),
        fragment("min(CAST(ROUND(CAST (?->>'value' AS NUMERIC), 2) AS FLOAT))", c)
      ]
    )
  end

  defp group_by_date_query(subquery, param_uuid, aggregator, grp_interval)
       when aggregator == "max" do
    from(
      data in subquery,
      cross_join: c in fragment("unnest(?)", data.parameters),
      where: fragment("?->>'uuid'=?", c, ^param_uuid),
      group_by: fragment("date_filt"),
      order_by: fragment("date_filt"),
      select: [
        fragment(
          "EXTRACT(EPOCH FROM (date_trunc(?, ?)))*1000 as date_filt",
          ^grp_interval,
          data.inserted_timestamp
        ),
        fragment("max(CAST(ROUND(CAST (?->>'value' AS NUMERIC), 2) AS FLOAT))", c)
      ]
    )
  end

  defp group_by_date_query(subquery, param_uuid, aggregator, grp_interval)
       when aggregator == "sum" do
    from(
      data in subquery,
      cross_join: c in fragment("unnest(?)", data.parameters),
      where: fragment("?->>'uuid'=?", c, ^param_uuid),
      group_by: fragment("date_filt"),
      order_by: fragment("date_filt"),
      select: [
        fragment(
          "EXTRACT(EPOCH FROM (date_trunc(?, ?)))*1000 as date_filt",
          ^grp_interval,
          data.inserted_timestamp
        ),
        fragment("sum(CAST(ROUND(CAST (?->>'value' AS NUMERIC), 2) AS FLOAT))", c)
      ]
    )
  end

  defp group_by_date_query(subquery, param_uuid, aggregator, grp_interval)
       when aggregator == "count" do
    from(
      data in subquery,
      cross_join: c in fragment("unnest(?)", data.parameters),
      where: fragment("?->>'uuid'=?", c, ^param_uuid),
      group_by: fragment("date_filt"),
      order_by: fragment("date_filt"),
      select: [
        fragment(
          "EXTRACT(EPOCH FROM (date_trunc(?, ?)))*1000 as date_filt",
          ^grp_interval,
          data.inserted_timestamp
        ),
        fragment("count(CAST(ROUND(CAST (?->>'value' AS NUMERIC), 2) AS FLOAT))", c)
      ]
    )
  end

  defp group_by_date_query(subquery, param_uuid, aggregator, grp_interval)
       when aggregator == "average" do
    from(
      data in subquery,
      cross_join: c in fragment("unnest(?)", data.parameters),
      where: fragment("?->>'uuid'=?", c, ^param_uuid),
      group_by: fragment("date_filt"),
      order_by: fragment("date_filt"),
      select: [
        fragment(
          "EXTRACT(EPOCH FROM (date_trunc(?, ?)))*1000 as date_filt",
          ^grp_interval,
          data.inserted_timestamp
        ),
        fragment("avg(CAST(ROUND(CAST (?->>'value' AS NUMERIC), 2) AS FLOAT))", c)
      ]
    )
  end
end
