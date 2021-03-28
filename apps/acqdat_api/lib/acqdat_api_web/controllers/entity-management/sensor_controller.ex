defmodule AcqdatApiWeb.EntityManagement.SensorController do
  use AcqdatApiWeb, :authorized_controller
  alias AcqdatApi.EntityManagement.Sensor
  alias AcqdatCore.Model.EntityManagement.Sensor, as: SensorModel
  import AcqdatApiWeb.Helpers
  alias AcqdatCore.ElasticSearch
  alias AcqdatApiWeb.EntityManagement.SensorErrorHelper
  import AcqdatApiWeb.Validators.EntityManagement.Sensor

  plug AcqdatApiWeb.Plug.LoadOrg
  plug AcqdatApiWeb.Plug.LoadProject
  plug :load_sensor when action in [:update, :delete, :show]

  def search_sensors(conn, params) do
    case conn.status do
      nil ->
        with {:ok, hits} <- ElasticSearch.search_entities("sensors", params) do
          conn |> put_status(200) |> render("hits.json", %{hits: hits})
        else
          {:error, message} ->
            conn
            |> send_error(404, SensorErrorHelper.error_message(:elasticsearch, message))
        end

      404 ->
        conn
        |> send_error(404, SensorErrorHelper.error_message(:resource_not_found))

      401 ->
        conn
        |> send_error(401, SensorErrorHelper.error_message(:unauthorized))
    end
  end

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
        |> send_error(404, SensorErrorHelper.error_message(:resource_not_found))

      401 ->
        conn
        |> send_error(401, SensorErrorHelper.error_message(:unauthorized))
    end
  end

  def index(conn, params) do
    case conn.status do
      nil ->
        with {:ok, hits} <- ElasticSearch.entities_indexing("sensors", params) do
          conn |> put_status(200) |> render("hits.json", %{hits: hits})
        else
          {:error, message} ->
            conn
            |> send_error(404, SensorErrorHelper.error_message(:elasticsearch, message))
        end

      404 ->
        conn
        |> send_error(404, SensorErrorHelper.error_message(:resource_not_found))

      401 ->
        conn
        |> send_error(401, SensorErrorHelper.error_message(:unauthorized))
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
            response =
              case is_map(message.error) do
                false -> message
                true -> message.error
              end

            send_error(conn, 400, response)
        end

      404 ->
        conn
        |> send_error(404, SensorErrorHelper.error_message(:resource_not_found))

      401 ->
        conn
        |> send_error(401, SensorErrorHelper.error_message(:unauthorized))
    end
  end

  def update(conn, params) do
    case conn.status do
      nil ->
        %{assigns: %{sensor: sensor}} = conn

        case SensorModel.update(sensor, params) do
          {:ok, sensor} ->
            Task.start_link(fn ->
              ElasticSearch.insert_sensor("sensors", sensor)
            end)

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
        |> send_error(404, SensorErrorHelper.error_message(:resource_not_found))

      401 ->
        conn
        |> send_error(401, SensorErrorHelper.error_message(:unauthorized))
    end
  end

  def delete(conn, %{"id" => id}) do
    case conn.status do
      nil ->
        case SensorModel.delete(id) do
          {:ok, sensor} ->
            Task.start_link(fn ->
              ElasticSearch.delete("sensors", sensor.id)
            end)

            conn
            |> put_status(200)
            |> render("sensor_delete.json", %{sensor: sensor})

          {:error, message} ->
            error =
              case String.valid?(message) do
                true -> SensorErrorHelper.error_message(:iot_data_existence, message)
                false -> extract_changeset_error(message)
              end

            conn
            |> send_error(400, error)
        end

      404 ->
        conn
        |> send_error(404, SensorErrorHelper.error_message(:resource_not_found))

      401 ->
        conn
        |> send_error(401, SensorErrorHelper.error_message(:unauthorized))
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
