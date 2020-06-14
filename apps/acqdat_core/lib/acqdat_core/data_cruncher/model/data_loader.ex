defmodule AcqdatCore.DataCruncher.Model.Dataloader do
  @moduledoc """
  Module exposes functions to deal with different type of data sources.

  Data Cruncher can deal with different types of data.
  The different types of data can be
  - `Primary Data Sources`: The data stored for sensor or gateways.
  - `Secondary Data Sources`: Data generated by the data cruncher.
  """
  import Ecto.Query
  import Ecto.Query.API
  alias AcqdatCore.Schema.EntityManagement.SensorsData
  alias AcqdatCore.Repo

  @doc """
  Loads a stream of sensor data and returns it.

  The function creates a query stream from the supplied params.
  Expects a map with following keys
  - `sensor_id`: id of the sensor
  - `param_uuid`: uuid of the param to load data of
  - `date_from`: date from which to load data
  - `date_to`: date uptil which data to be loaded.
  """
  @spec load_stream(:pds | :sds, map) :: Stream.t()
  def load_stream(:pds, params) do
    %{sensor_id: sensor_id, param_uuid: param_uuid,
       date_from: date_from, date_to: date_to} = params

    subquery = from(
      data in SensorsData,
      where: data.sensor_id == ^sensor_id and data.inserted_timestamp >= ^date_from and
        data.inserted_timestamp <= ^date_to
    )

    query = from(
      data in subquery,
      cross_join: c in fragment("unnest(?)", data.parameters),
      where: fragment("?->>'uuid'=?", c, ^param_uuid),
      select: [data.inserted_timestamp,
        fragment("?->>'value'", c),
        fragment("?->>'name'", c),
        fragment("?->>'uuid'", c)
      ]
    )
    Repo.stream(query)
  end

  # TODO: to be added later
  def load_stream(:sds, _params) do
    Stream.map([], fn x -> x end)
  end

end
