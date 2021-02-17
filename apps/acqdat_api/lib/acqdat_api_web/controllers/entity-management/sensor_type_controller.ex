defmodule AcqdatApiWeb.EntityManagement.SensorTypeController do
  use AcqdatApiWeb, :authorized_controller
  alias AcqdatApi.EntityManagement.SensorType
  alias AcqdatCore.ElasticSearch
  alias AcqdatApiWeb.EntityManagement.SensorTypeErrorHelper
  import AcqdatApiWeb.Helpers
  import AcqdatApiWeb.Validators.EntityManagement.SensorType

  plug AcqdatApiWeb.Plug.LoadSensorType when action in [:update, :delete, :show]

  def search_sensor_type(conn, params) do
    case conn.status do
      nil ->
        with {:ok, hits} <- ElasticSearch.search_entities("sensor_types", params) do
          conn |> put_status(200) |> render("hits.json", %{hits: hits})
        else
          {:error, message} ->
            conn
            |> send_error(404, SensorTypeErrorHelper.error_message(:elasticsearch_error, message))
        end

      404 ->
        conn
        |> send_error(404, SensorTypeErrorHelper.error_message(:resource_not_found))

      401 ->
        conn
        |> send_error(401, SensorTypeErrorHelper.error_message(:unauthorized))
    end
  end

  def index(conn, params) do
    case conn.status do
      nil ->
        with {:ok, hits} <- ElasticSearch.entities_indexing("sensor_types", params) do
          conn |> put_status(200) |> render("hits.json", %{hits: hits})
        else
          {:error, message} ->
            conn
            |> send_error(404, SensorTypeErrorHelper.error_message(:elasticsearch_error, message))
        end

      404 ->
        conn
        |> send_error(404, SensorTypeErrorHelper.error_message(:resource_not_found))

      401 ->
        conn
        |> send_error(401, SensorTypeErrorHelper.error_message(:unauthorized))
    end
  end

  def create(conn, params) do
    case conn.status do
      nil ->
        changeset = verify_sensor_params(params)

        with {:extract, {:ok, data}} <- {:extract, extract_changeset_data(changeset)},
             {:create, {:ok, sensor_type}} <- {:create, SensorType.create(data)} do
          Task.start_link(fn ->
            ElasticSearch.insert_sensor_type("sensor_types", sensor_type)
          end)

          conn
          |> put_status(200)
          |> render("sensor_type.json", %{sensor_type: sensor_type})
        else
          {:extract, {:error, error}} ->
            send_error(conn, 400, error)

          {:create, {:error, message}} ->
            send_error(conn, 400, message.error)
        end

      404 ->
        conn
        |> send_error(404, SensorTypeErrorHelper.error_message(:resource_not_found))

      401 ->
        conn
        |> send_error(401, SensorTypeErrorHelper.error_message(:unauthorized))
    end
  end

  @spec update(Plug.Conn.t(), any) :: Plug.Conn.t()
  def update(conn, params) do
    case conn.status do
      nil ->
        %{assigns: %{sensor_type: sensor_type}} = conn

        case SensorType.update(sensor_type, params) do
          {:ok, sensor_type} ->
            Task.start_link(fn ->
              ElasticSearch.insert_sensor_type("sensor_types", sensor_type)
            end)

            conn
            |> put_status(200)
            |> render("sensor_type.json", %{sensor_type: sensor_type})

          {:error, %Ecto.Changeset{} = changeset} ->
            error = extract_changeset_error(changeset)

            conn
            |> send_error(400, error)

          {:error, error} ->
            conn
            |> send_error(400, SensorTypeErrorHelper.error_message(:sensor_association, error))
        end

      404 ->
        conn
        |> send_error(404, SensorTypeErrorHelper.error_message(:resource_not_found))

      401 ->
        conn
        |> send_error(401, SensorTypeErrorHelper.error_message(:unauthorized))
    end
  end

  def delete(conn, _params) do
    case conn.status do
      nil ->
        %{assigns: %{sensor_type: sensor_type}} = conn

        case SensorType.delete(sensor_type) do
          {:ok, sensor_type} ->
            Task.start_link(fn ->
              ElasticSearch.delete("sensor_types", sensor_type.id)
            end)

            conn
            |> put_status(200)
            |> render("sensor_type.json", %{sensor_type: sensor_type})

          {:error, %Ecto.Changeset{} = changeset} ->
            error = extract_changeset_error(changeset)

            conn
            |> send_error(400, error)

          {:error, error} ->
            conn
            |> send_error(400, SensorTypeErrorHelper.error_message(:sensor_association, error))
        end

      404 ->
        conn
        |> send_error(404, SensorTypeErrorHelper.error_message(:resource_not_found))

      401 ->
        conn
        |> send_error(401, SensorTypeErrorHelper.error_message(:unauthorized))
    end
  end
end
