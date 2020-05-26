defmodule AcqdatApiWeb.EntityManagement.SensorTypeController do
  use AcqdatApiWeb, :controller
  alias AcqdatApi.EntityManagement.SensorType
  alias AcqdatCore.Model.EntityManagement.SensorType, as: SensorTypeModel
  import AcqdatApiWeb.Helpers
  import AcqdatApiWeb.Validators.EntityManagement.SensorType

  plug AcqdatApiWeb.Plug.LoadSensorType when action in [:update, :delete, :show]

  # Will be used in future.
  # def show(conn, %{"id" => id}) do
  #   case conn.status do
  #     nil ->
  #       {id, _} = Integer.parse(id)
  #       {:list, {:ok, sensor}} = {:list, SensorModel.get(id)}

  #       conn
  #       |> put_status(200)
  #       |> render("sensor.json", sensor)

  #     404 ->
  #       conn
  #       |> send_error(404, "Resource Not Found")
  #   end
  # end

  def index(conn, params) do
    changeset = verify_index_params(params)

    case conn.status do
      nil ->
        {:extract, {:ok, data}} = {:extract, extract_changeset_data(changeset)}
        {:list, sensor} = {:list, SensorTypeModel.get_all(data, [:org])}

        conn
        |> put_status(200)
        |> render("index.json", sensor)

      404 ->
        conn
        |> send_error(404, "Resource Not Found")
    end
  end

  @spec create(Plug.Conn.t(), any) :: Plug.Conn.t()
  def create(conn, params) do
    case conn.status do
      nil ->
        changeset = verify_sensor_params(params)

        with {:extract, {:ok, data}} <- {:extract, extract_changeset_data(changeset)},
             {:create, {:ok, sensor_type}} <- {:create, SensorType.create(data)} do
          conn
          |> put_status(200)
          |> render("sensor_type.json", %{sensor_type: sensor_type})
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

  @spec update(Plug.Conn.t(), any) :: Plug.Conn.t()
  def update(conn, params) do
    case conn.status do
      nil ->
        %{assigns: %{sensor_type: sensor_type}} = conn

        case SensorTypeModel.update(sensor_type, params) do
          {:ok, sensor_type} ->
            conn
            |> put_status(200)
            |> render("sensor_type.json", %{sensor_type: sensor_type})

          {:error, sensor_type} ->
            error =
              case String.valid?(sensor_type) do
                false -> extract_changeset_error(sensor_type)
                true -> sensor_type
              end

            conn
            |> send_error(400, error)
        end

      404 ->
        conn
        |> send_error(404, "Resource Not Found")
    end
  end

  def delete(conn, _params) do
    case conn.status do
      nil ->
        %{assigns: %{sensor_type: sensor_type}} = conn

        case SensorTypeModel.delete(sensor_type) do
          {:ok, sensor_type} ->
            conn
            |> put_status(200)
            |> render("sensor_type.json", %{sensor_type: sensor_type})

          {:error, sensor_type} ->
            error =
              case String.valid?(sensor_type) do
                false -> extract_changeset_error(sensor_type)
                true -> sensor_type
              end

            conn
            |> send_error(400, error)
        end

      404 ->
        conn
        |> send_error(404, "Resource Not Found")
    end
  end
end
