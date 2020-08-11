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

  def get_all_by_parameters(entity_id, param_uuid, date_from, date_to) do
    subquery =
      from(
        data in SensorsData,
        where:
          data.sensor_id == ^entity_id and data.inserted_timestamp >= ^date_from and
            data.inserted_timestamp <= ^date_to,
        order_by: [asc: data.inserted_timestamp]
      )

    query =
      from(
        data in subquery,
        cross_join: c in fragment("unnest(?)", data.parameters),
        where: fragment("?->>'uuid'=?", c, ^param_uuid),
        select: [
          fragment("EXTRACT(EPOCH FROM ?)*1000", data.inserted_timestamp),
          fragment("?->>'value'", c)
        ]
      )

    Repo.all(query)
  end
end
