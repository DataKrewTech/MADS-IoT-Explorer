defmodule AcqdatApiWeb.DataInsights.PivotTablesController do
  use AcqdatApiWeb, :controller
  import AcqdatApiWeb.Helpers
  import AcqdatApiWeb.Validators.DataInsights.PivotTables
  alias AcqdatApi.DataInsights.PivotTables

  plug AcqdatApiWeb.Plug.LoadCurrentUser
  plug AcqdatApiWeb.Plug.LoadProject
  plug AcqdatApiWeb.Plug.LoadPivot when action in [:update, :delete, :show]

  def index(conn, params) do
    changeset = verify_index_params(params)

    case conn.status do
      nil ->
        {:extract, {:ok, data}} = {:extract, extract_changeset_data(changeset)}
        {:list, pivot_tables} = {:list, PivotTables.get_all(data)}

        conn
        |> put_status(200)
        |> render("index.json", pivot_tables)

      404 ->
        conn
        |> send_error(404, "Resource Not Found")
    end
  end

  def show(conn, _params) do
    case conn.status do
      nil ->
        conn
        |> put_status(200)
        |> render("show.json", %{pivot_table: conn.assigns.pivot})

      404 ->
        conn
        |> send_error(404, "Resource Not Found")
    end
  end

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
        case PivotTables.update_pivot_data(params, conn.assigns.pivot) do
          {:error, %Ecto.Changeset{} = changeset} ->
            error = extract_changeset_error(changeset)
            send_error(conn, 400, error)

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

  def delete(conn, _params) do
    case conn.status do
      nil ->
        case PivotTables.delete(conn.assigns.pivot) do
          {:ok, pivot_table} ->
            conn
            |> put_status(200)
            |> render("create.json", %{pivot_table: pivot_table})

          {:error, %Ecto.Changeset{} = changeset} ->
            error = extract_changeset_error(changeset)
            send_error(conn, 400, error)

          {:error, message} ->
            conn
            |> send_error(404, message)
        end

      404 ->
        conn
        |> send_error(404, "Resource Not Found")
    end
  end
end
