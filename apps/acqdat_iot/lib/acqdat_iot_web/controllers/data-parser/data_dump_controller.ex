defmodule AcqdatIotWeb.DataParser.DataDumpController do
  use AcqdatIotWeb, :controller
  alias AcqdatCore.IotManager.DataDump.Worker.Server
  import AcqdatIoTWeb.Helpers
  import AcqdatIoTWeb.Validators.DataParser.DataDump

  plug AcqdatIoTWeb.Plug.LoadProject
  plug AcqdatIoTWeb.Plug.LoadOrg
  plug AcqdatIoTWeb.Plug.LoadGateway

  @doc """
  Adds data recieved from gateway to IoT Storage.

  TODO: At present data being received is not enriched and needs the client
  to send data in our format inspite of providing mapped parameters support
  we need to modify this so gateway_id doesn't need to be part of the json
  being sent both for MQTT as well as HTTP. For HTTP we can do it by using
  query params instead of putting ids in body.
  """
  def create(conn, params) do
    case conn.status do
      nil ->
        changeset = verify_dumping_data(params)

        case extract_changeset_data(changeset) do
          {:ok, data} ->
            data =
              data
              |> Map.from_struct()
              |> Map.drop([:_id, :__meta__])

            Server.create(data)

            conn
            |> put_status(202)
            |> json(%{"data inserted" => true})

          {:error, error} ->
            send_error(conn, 400, error)
        end

      404 ->
        conn
        |> send_error(404, "Unauthorized")
    end
  end
end
