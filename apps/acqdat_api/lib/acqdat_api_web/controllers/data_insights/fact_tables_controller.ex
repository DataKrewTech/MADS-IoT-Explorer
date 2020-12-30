defmodule AcqdatApiWeb.DataInsights.FactTablesController do
  use AcqdatApiWeb, :controller
  import AcqdatApiWeb.Helpers
  alias AcqdatApi.DataInsights.FactTables

  plug AcqdatApiWeb.Plug.LoadCurrentUser
  plug AcqdatApiWeb.Plug.LoadProject

  def create(conn, %{"org_id" => org_id}) do
    case conn.status do
      nil ->
        case FactTables.create(org_id, conn.assigns.project) do
          {:ok, fact_table} ->
            conn
            |> put_status(200)
            |> render("create.json", %{fact_table: fact_table})

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
end
