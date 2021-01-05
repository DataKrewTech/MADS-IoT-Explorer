defmodule AcqdatApiWeb.DataInsights.PivotTablesController do
  use AcqdatApiWeb, :controller
  import AcqdatApiWeb.Helpers
  alias AcqdatApi.DataInsights.Topology

  plug AcqdatApiWeb.Plug.LoadCurrentUser
  plug AcqdatApiWeb.Plug.LoadProject

  def create(conn, params) do
    case conn.status do
      nil ->
        case Topology.gen_pivot_table(params) do
          {:error, %Ecto.Changeset{} = changeset} ->
            error = extract_changeset_error(changeset)

            conn
            |> send_error(400, error)

          {:error, error} ->
            conn
            |> send_error(400, error)

          {:ok, data} ->
            conn
            |> put_status(200)
            |> render("pivot_table_data.json", %{pivot_table: data[:gen_pivot_data]})
        end

      404 ->
        conn
        |> send_error(404, "Resource Not Found")
    end
  end
end
