defmodule AcqdatApiWeb.DataInsights.PivotTablesController do
  use AcqdatApiWeb, :controller
  import AcqdatApiWeb.Helpers
  alias AcqdatApi.DataInsights.Topology
  alias AcqdatApi.DataInsights.PivotTables

  plug AcqdatApiWeb.Plug.LoadCurrentUser
  plug AcqdatApiWeb.Plug.LoadProject
  plug AcqdatApiWeb.Plug.LoadPivot when action in [:update]

  def create(conn, %{"org_id" => org_id, "fact_tables_id" => fact_tables_id}) do
    case conn.status do
      nil ->
        case PivotTables.create(org_id, fact_tables_id, conn.assigns.project) do
          {:ok, pivot_table} ->
            conn
            |> put_status(200)
            |> render("create.json", %{pivot_table: pivot_table})

          {:error, %Ecto.Changeset{} = changeset} ->
            error = extract_changeset_error(changeset)

            conn
            |> send_error(400, error)

          {:error, error} ->
            conn
            |> send_error(400, error)
        end

      404 ->
        conn
        |> send_error(404, "Resource Not Found")
    end
  end

  def update(conn, params) do
    case conn.status do
      nil ->
        case Topology.update_pivot_data(params, conn.assigns.pivot) do
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
