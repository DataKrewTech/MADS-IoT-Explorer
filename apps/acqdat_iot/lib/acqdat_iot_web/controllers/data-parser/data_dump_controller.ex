defmodule AcqdatIotWeb.DataParser.DataDumpController do
  use AcqdatIotWeb, :controller
  alias AcqdatIot.DataDump
  import AcqdatApiWeb.Helpers
  import AcqdatApiWeb.Validators.DataParser.DataDump

  plug AcqdatApiWeb.Plug.LoadProject
  plug AcqdatApiWeb.Plug.LoadOrg
  plug AcqdatApiWeb.Plug.LoadGateway

  def create(conn, params) do
    case conn.status do
      nil ->
        changeset = verify_dumping_data(params)

        case extract_changeset_data(changeset) do
          {:ok, data} ->
            case DataDump.create(data) do
              {:ok, command} ->
                conn
                |> put_status(200)
                |> render("command.json", %{command: command})

              {:error, message} ->
                conn
                |> put_status(200)
                |> json(%{"data inserted" => true, "command" => nil})
            end

          {:error, error} ->
            send_error(conn, 400, error)
        end

      404 ->
        conn
        |> send_error(404, "Unauthorized")
    end
  end
end
