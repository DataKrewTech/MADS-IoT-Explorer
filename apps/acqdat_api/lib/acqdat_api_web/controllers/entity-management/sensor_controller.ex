defmodule AcqdatApiWeb.EntityManagement.SensorController do
  use AcqdatApiWeb, :controller
  alias AcqdatApi.EntityManagement.Sensor
  alias AcqdatCore.Model.EntityManagement.Sensor, as: SensorModel
  import AcqdatApiWeb.Helpers
  import AcqdatApiWeb.Validators.EntityManagement.Sensor

  plug AcqdatApiWeb.Plug.LoadOrg
  plug AcqdatApiWeb.Plug.LoadProject
  plug :load_sensor when action in [:update, :delete, :show]

  def show(conn, %{"id" => id}) do
    case conn.status do
      nil ->
        {id, _} = Integer.parse(id)
        {:list, {:ok, sensor}} = {:list, SensorModel.get(id)}

        conn
        |> put_status(200)
        |> render("sensor.json", sensor)

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
        {:list, sensor} = {:list, SensorModel.get_all_by_assets(data)}

        conn
        |> put_status(200)
        |> render("index.json", sensor)

      404 ->
        conn
        |> send_error(404, "Resource Not Found")
    end
  end

  def create(conn, params) do
    case conn.status do
      nil ->
        changeset = verify_sensor_create_params(params)

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
end
