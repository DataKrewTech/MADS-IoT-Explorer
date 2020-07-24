defmodule AcqdatIotWeb.DataParser.DataDumpController do
  use AcqdatIotWeb, :controller
  alias AcqdatCore.IotManager.DataDump.Worker.Server
  import AcqdatIoTWeb.Helpers
  import AcqdatIoTWeb.Validators.DataParser.DataDump

  plug AcqdatIoTWeb.Plug.LoadProject
  plug AcqdatIoTWeb.Plug.LoadOrg
  plug AcqdatIoTWeb.Plug.LoadGateway

  def create(conn, params) do
    case conn.status do
      nil ->
        changeset = verify_dumping_data(params)

        case extract_changeset_data(changeset) do
          {:ok, data} ->
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
