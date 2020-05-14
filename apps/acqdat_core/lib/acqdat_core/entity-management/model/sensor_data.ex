defmodule AcqdatCore.Model.EntityManagement.SensorData do
  @moduledoc """
  The Module exposes helper functions to interact with sensor
  data.
  """
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
end
