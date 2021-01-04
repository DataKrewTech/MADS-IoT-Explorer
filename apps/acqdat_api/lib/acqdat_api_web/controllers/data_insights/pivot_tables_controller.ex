defmodule AcqdatApiWeb.DataInsights.PivotTablesController do
  use AcqdatApiWeb, :controller
  import AcqdatApiWeb.Helpers
  alias AcqdatApi.DataInsights.Topology

  plug AcqdatApiWeb.Plug.LoadCurrentUser
  plug AcqdatApiWeb.Plug.LoadProject

  def create(conn, %{
        "org_id" => org_id,
        "project_id" => project_id,
        "fact_tables_id" => fact_tables_id,
        "user_list" => user_list
      }) do
    case conn.status do
      nil ->
        case Topology.pivot_table("fact_table_#{fact_tables_id}", user_list) do
          {:error, message} ->
            conn
            |> send_error(404, message)

          data ->
            conn
            |> put_status(200)
            |> render("pivot_table_data.json", %{pivot_table: data})
        end

      404 ->
        conn
        |> send_error(404, "Resource Not Found")
    end
  end
end
