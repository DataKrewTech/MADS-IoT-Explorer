defmodule AcqdatApiWeb.Plug.LoadSensorType do
  import Plug.Conn
  alias AcqdatCore.Model.EntityManagement.SensorType, as: SensorTypeModel

  def init(default), do: default

  def call(%{params: %{"id" => id}} = conn, _params) do
    load_sensor_type(conn, id)
  end

  def load_sensor_type(conn, id) do
    {id, _} = Integer.parse(id)

    case SensorTypeModel.get(id) do
      {:ok, sensor_type} ->
        assign(conn, :sensor_type, sensor_type)

      {:error, _message} ->
        conn
        |> put_status(404)
    end
  end
end
