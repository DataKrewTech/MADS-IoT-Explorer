defmodule AcqdatApiWeb.SensorNotificationController do
  use AcqdatApiWeb, :controller
  alias AcqdatApi.SensorNotification
  alias AcqdatCore.Model.Sensor, as: SensorModel
  alias AcqdatCore.Model.SensorNotification, as: SensorNotificationModel
  import AcqdatApiWeb.Helpers
  import AcqdatApiWeb.Validators.SensorNotification

  plug :check_sensor when action in [:create]
  plug :load_sensor_notification when action in [:update, :delete, :show]

  def show(conn, %{"id" => id}) do
    case conn.status do
      nil ->
        {:list, {:ok, sensor_notification}} = {:list, SensorNotificationModel.get(id)}

        conn
        |> put_status(200)
        |> render("sensor_notification_with_device.json", sensor_notification)

      404 ->
        conn
        |> send_error(404, "Resource Not Found")
    end
  end

  def index(conn, params) do
    changeset = verify_index_params(params)

    case conn.status do
      nil ->
        {:extract, {:ok, data}} = {:extract, extract_changeset_data(changeset)}
        {:list, sensor_notification} = {:list, SensorNotificationModel.get_all(data, [:sensor])}

        conn
        |> put_status(200)
        |> render("index.json", sensor_notification)

      404 ->
        conn
        |> send_error(404, "Resource Not Found")
    end
  end

  def create(conn, params) do
    case conn.status do
      nil ->
        changeset = verify_sensor_notification_params(params)

        with {:extract, {:ok, data}} <- {:extract, extract_changeset_data(changeset)},
             {:create, {:ok, sensor_notification}} <- {:create, SensorNotification.create(data)} do
          conn
          |> put_status(200)
          |> render("sensor_notification.json", %{sensor_notification: sensor_notification})
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
        %{assigns: %{sensor_notification: sensor_notification}} = conn

        case SensorNotificationModel.update(sensor_notification, params) do
          {:ok, sensor_notification} ->
            conn
            |> put_status(200)
            |> render("sensor_notification.json", %{sensor_notification: sensor_notification})

          {:error, sensor_notification} ->
            error = extract_changeset_error(sensor_notification)

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
        case SensorNotificationModel.delete(id) do
          {:ok, sensor_notification} ->
            conn
            |> put_status(200)
            |> render("sensor_notification.json", %{sensor_notification: sensor_notification})

          {:error, sensor_notification} ->
            error = extract_changeset_error(sensor_notification)

            conn
            |> send_error(400, error)
        end

      404 ->
        conn
        |> send_error(404, "Resource Not Found")
    end
  end

  defp check_sensor(%{params: %{"sensor_id" => id}} = conn, _params) do
    case SensorModel.get(id) do
      {:ok, sensor} ->
        assign(conn, :sensor, sensor)

      {:error, _message} ->
        conn
        |> put_status(404)
    end
  end

  defp load_sensor_notification(%{params: %{"id" => id}} = conn, _params) do
    {id, _} = Integer.parse(id)

    case SensorNotificationModel.get(id) do
      {:ok, sensor_notification} ->
        assign(conn, :sensor_notification, sensor_notification)

      {:error, _message} ->
        conn
        |> put_status(404)
    end
  end
end
