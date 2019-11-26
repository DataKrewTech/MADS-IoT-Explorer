defmodule AcqdatApiWeb.SensorController do
  use AcqdatApiWeb, :controller
  alias AcqdatApi.Sensor
  alias AcqdatCore.Model.Device, as: DeviceModel
  alias AcqdatCore.Model.Sensor, as: SensorModel
  alias AcqdatCore.Model.SensorType, as: SensorTypeModel
  import AcqdatApiWeb.Helpers
  import AcqdatApiWeb.Validators.Sensor

  plug :load_device_and_sensor_type when action in [:create]
  plug :load_sensor when action in [:update, :delete]
  plug :load_device when action in [:sensor_by_criteria]

  def index(conn, params) do
    changeset = verify_index_params(params)

    case conn.status do
      nil ->
        {:extract, {:ok, data}} = {:extract, extract_changeset_data(changeset)}
        {:list, sensor} = {:list, SensorModel.get_all(data, [:sensor_type, :device])}

        conn
        |> put_status(200)
        |> render("index.json", sensor)

      404 ->
        conn
        |> send_error(404, "Resource Not Found")
    end
  end

  def sensor_by_criteria(conn, %{"device_id" => device_id}) do
    {device_id, _} = Integer.parse(device_id)

    case conn.status do
      nil ->
        {:list, device_sensors} =
          {:list, SensorModel.get_all_by_device(device_id, [:sensor_type])}
          
          conn
          |> put_status(200)
          |> render("device_sensor_with_preloads.json", device_sensors: device_sensors)
        

      404 ->
        conn
        |> send_error(404, "Resource Not Found")
    end
  end
  
  def create(conn, params) do
    case conn.status do
      nil ->
        changeset = verify_sensor_params(params)

        with {:extract, {:ok, data}} <- {:extract, extract_changeset_data(changeset)},
             {:create, {:ok, sensor}} <- {:create, Sensor.create(data)} do
          conn
          |> put_status(200)
          |> render("sensor.json", %{sensor: sensor})
        else
          {:extract, {:error, error}} ->
            send_error(conn, 400, error)

          {:create, {:error, message}} ->
            send_error(conn, 400, message)
        end

      404 ->
        conn
        |> send_error(404, "Resource Not Found")
    end
  end

  def update(conn, params) do
    case conn.status do
      nil ->
        %{assigns: %{sensor: sensor}} = conn

        case SensorModel.update(sensor, params) do
          {:ok, sensor} ->
            conn
            |> put_status(200)
            |> render("sensor.json", %{sensor: sensor})

          {:error, sensor} ->
            error = extract_changeset_error(sensor)

            conn
            |> send_error(400, error)
        end

      404 ->
        conn
        |> send_error(404, "Resource Not Found")
    end
  end

  def delete(conn, %{"id" => id}) do
    case conn.status do
      nil ->
        case SensorModel.delete(id) do
          {:ok, sensor} ->
            conn
            |> put_status(200)
            |> render("sensor.json", %{sensor: sensor})

          {:error, sensor} ->
            error = extract_changeset_error(sensor)

            conn
            |> send_error(400, error)
        end

      404 ->
        conn
        |> send_error(404, "Resource Not Found")
    end
  end

  defp load_sensor(%{params: %{"id" => id}} = conn, _params) do
    {id, _} = Integer.parse(id)

    case SensorModel.get(id) do
      {:ok, sensor} ->
        assign(conn, :sensor, sensor)

      {:error, _message} ->
        conn
        |> put_status(404)
    end
  end

  defp load_device_and_sensor_type(
         %{params: %{"device_id" => device_id, "sensor_type_id" => sensor_type_id}} = conn,
         _params
       ) do
    {device_id, _} = Integer.parse(device_id)
    {sensor_type_id, _} = Integer.parse(sensor_type_id)

    case DeviceModel.get(device_id) do
      {:ok, device} ->
        case SensorTypeModel.get(sensor_type_id) do
          {:ok, sensor_type} ->
            sensor_type = Map.put(sensor_type, :device, device)
            assign(conn, :sensor_type, sensor_type)

          {:error, _message} ->
            conn
            |> put_status(404)
        end

      {:error, _message} ->
        conn
        |> put_status(404)
    end
  end

  defp load_device(%{params: %{"device_id" => device_id}} = conn, _params) do
    {device_id, _} = Integer.parse(device_id)

    case DeviceModel.get(device_id) do
      {:ok, device} ->
        assign(conn, :device, device)

      {:error, _message} ->
        conn
        |> put_status(404)
    end
  end
end
