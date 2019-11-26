defmodule AcqdatApiWeb.DeviceController do
  use AcqdatApiWeb, :controller
  alias AcqdatApi.Device
  alias AcqdatCore.Model.Device, as: DeviceModel
  import AcqdatApiWeb.Helpers
  import AcqdatApiWeb.Validators.Device

  plug :load_device when action in [:update, :delete]

  def index(conn, params) do
    changeset = verify_index_params(params)

    case conn.status do
      nil ->
        {:extract, {:ok, data}} = {:extract, extract_changeset_data(changeset)}
        {:list, device} = {:list, DeviceModel.get_all(data)}
        
        conn
        |> put_status(200)
        |> render("index.json", device)

      404 ->
        conn
        |> send_error(404, "Resource Not Found")
    end
  end

  def create(conn, params) do
    changeset = verify_device_params(params)

    with {:extract, {:ok, data}} <- {:extract, extract_changeset_data(changeset)},
         {:create, {:ok, device}} <- {:create, Device.create(data)} do
      conn
      |> put_status(200)
      |> render("device.json", %{device: device})
    else
      {:extract, {:error, error}} ->
        send_error(conn, 400, error)

      {:create, {:error, message}} ->
        send_error(conn, 400, message)
    end
  end

  def update(conn, params) do
    case conn.status do
      nil ->
        %{assigns: %{device: device}} = conn

        case DeviceModel.update(device, params) do
          {:ok, device} ->
            conn
            |> put_status(200)
            |> render("device.json", %{device: device})

          {:error, device} ->
            error = extract_changeset_error(device)

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
        case DeviceModel.delete(id) do
          {:ok, device} ->
            conn
            |> put_status(200)
            |> render("device.json", %{device: device})

          {:error, device} ->
            error = extract_changeset_error(device)

            conn
            |> send_error(400, error)
        end

      404 ->
        conn
        |> send_error(404, "Resource Not Found")
    end
  end

  defp load_device(%{params: %{"id" => id}} = conn, _params) do
    {id, _} = Integer.parse(id)

    case DeviceModel.get(id) do
      {:ok, device} ->
        assign(conn, :device, device)

      {:error, _message} ->
        conn
        |> put_status(404)
    end
  end
end
