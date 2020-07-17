defmodule AcqdatIotWeb.DataParser.DataDumpController do
  use AcqdatIotWeb, :controller
  alias AcqdatIot.DataDump
  import AcqdatApiWeb.Helpers
  import AcqdatIoTWeb.Validators.DataParser.DataDump

  plug AcqdatApiWeb.Plug.LoadProject
  plug AcqdatApiWeb.Plug.LoadOrg
  plug AcqdatApiWeb.Plug.LoadGateway

  def create(conn, params) do
    case conn.status do
      nil ->
        changeset = verify_dumping_data(params)
        start_dumping(conn, extract_changeset_data(changeset))

      404 ->
        conn
        |> send_error(404, "Unauthorized")
    end
  end

  defp start_dumping(conn, {:ok, data}) do
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
  end

  defp start_dumping(conn, {:error, error}) do
    send_error(conn, 400, error)
  end
end
