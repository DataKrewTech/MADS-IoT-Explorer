defmodule AcqdatCore.Schema.EntityManagement.SensorData do
  @moduledoc """
  Models the schema where all the data is finally stored
  for all the devices and sensors.

  Each row in this table corresponds to a sensor value at
  a particular time, for a particular device.
  """

  use AcqdatCore.Schema
  alias AcqdatCore.Schema.EntityManagement.Sensor

  @typedoc """
  `inserted_timestamp`: The timestamp sent by device sending the sensor data.
  `datapoint`: Depicts the data point. Datapoint is a map containing different
               sensor values. The keys for this can be inferred from `value_keys`
               field of `sensor_type` device belongs to.
  """
  @type t :: %__MODULE__{}

  schema("acqdat_sensor_data") do
    field(:inserted_timestamp, :utc_datetime)
    field(:datapoint, :map)
    belongs_to(:sensor, Sensor)

    timestamps(type: :utc_datetime)
  end

  @required_params ~w(inserted_timestamp datapoint sensor_id)a

  @spec changeset(__MODULE__.t(), any()) :: Ecto.Changeset.t()
  def changeset(%__MODULE__{} = sensor_data, params) do
    sensor_data
    |> cast(params, @required_params)
    |> validate_required(@required_params)
    |> assoc_constraint(:sensor)
  end
end
