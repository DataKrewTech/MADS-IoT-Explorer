defmodule AcqdatIotWeb.DataParser.DataDumpController do
  use AcqdatIotWeb, :controller
  alias AcqdatIot.DataDump.Worker.Server
  alias AcqdatCore.Model.IotManager.GatewayDataDump
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

  def index(conn, params) do
    changeset = verify_index_params(params)

    case conn.status do
      nil ->
        {:extract, {:ok, data}} = {:extract, extract_changeset_data(changeset)}
        {:list, data_dump} = {:list, GatewayDataDump.get_all(data, [:org, :project])}

        conn
        |> put_status(200)
        |> render("index.json", data_dump)

      404 ->
        conn
        |> send_error(404, "Unauthorized")
    end
  end
end
