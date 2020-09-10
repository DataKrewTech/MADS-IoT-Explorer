defmodule AcqdatCore.Model.EntityManagement.SensorData do
  @moduledoc """
  The Module exposes helper functions to interact with sensor
  data.
  """

  alias AcqdatCore.Schema.EntityManagement.SensorsData
  alias AcqdatCore.Domain.EntityManagement.SensorData, as: SensorDataDomain
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
  # NOTE: group_interval supported formats: second, minute, hour, day, week
  def get_all_by_parameters(entity_id, param_uuid, %{
        from_date: date_from,
        to_date: date_to,
        aggregate_func: aggregate_func,
        group_interval: group_interval,
        group_interval_type: group_interval_type
      }) do
    subquery = SensorDataDomain.filter_by_date_query(entity_id, date_from, date_to)

    query =
      SensorDataDomain.group_by_date_query(
        subquery,
        param_uuid,
        aggregate_func,
        group_interval,
        group_interval_type
      )

    Repo.all(query)
  end

  def get_latest_by_parameters(entity_id, param_uuid, %{
        from_date: date_from,
        to_date: date_to,
        aggregate_func: aggregate_func,
        group_interval: group_interval,
        group_interval_type: group_interval_type
      }) do
    subquery = SensorDataDomain.filter_by_date_query(entity_id, date_from, date_to)

    query =
      SensorDataDomain.latest_group_by_date_query(
        subquery,
        param_uuid,
        aggregate_func,
        group_interval,
        group_interval_type
      )

    Repo.one(query)
  end
end
