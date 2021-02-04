defmodule AcqdatApiWeb.DataInsights.FactTablesController do
  use AcqdatApiWeb, :controller
  import AcqdatApiWeb.Helpers
  import AcqdatApiWeb.Validators.DataInsights.FactTables
  alias AcqdatApi.DataInsights.{FactTables, Topology}

  plug AcqdatApiWeb.Plug.LoadCurrentUser
  plug AcqdatApiWeb.Plug.LoadProject
  plug AcqdatApiWeb.Plug.LoadFact when action in [:update, :delete, :details]

  def index(conn, params) do
    changeset = verify_index_params(params)

    case conn.status do
      nil ->
        {:extract, {:ok, data}} = {:extract, extract_changeset_data(changeset)}
        {:list, fact_tables} = {:list, FactTables.get_all(data)}

        conn
        |> put_status(200)
        |> render("index.json", fact_tables)

      404 ->
        conn
        |> send_error(404, "Resource Not Found")
    end
  end

  def create(conn, %{"name" => name, "org_id" => org_id}) do
    case conn.status do
      nil ->
        case FactTables.create(name, org_id, conn.assigns.project, conn.assigns.current_user) do
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

  def show(conn, params) do
    case conn.status do
      nil ->
        case FactTables.fetch_name_by_id(params) do
          {:error, message} ->
            conn
            |> send_error(404, message)

          data ->
            conn
            |> put_status(200)
            |> render("fact_table_data.json", %{fact_table: data[:data]})
        end

      404 ->
        conn
        |> send_error(404, "Resource Not Found")
    end
  end

  def details(conn, %{"fact_tables_id" => fact_tables_id}) do
    case conn.status do
      nil ->
        conn
        |> put_status(200)
        |> render("fact_table_details.json", %{
          fact_table: FactTables.fetch_fact_table_headers(conn.assigns.fact_table)
        })

      404 ->
        conn
        |> send_error(404, "Resource Not Found")
    end
  end

  def update(conn, %{
        "org_id" => org_id,
        "project_id" => project_id,
        "id" => id,
        "user_list" => user_list,
        "name" => name
      }) do
    case conn.status do
      nil ->
        case Topology.gen_sub_topology(
               id,
               org_id,
               conn.assigns.project,
               name,
               conn.assigns.fact_table,
               user_list
             ) do
          {:error, %Ecto.Changeset{} = changeset} ->
            error = extract_changeset_error(changeset)
            send_error(conn, 400, error)

          {:error, message} ->
            conn
            |> send_error(404, message)

          {:ok, data} ->
            conn
            |> put_status(200)
            |> render("fact_table_data.json", %{fact_table: data})
        end

      404 ->
        conn
        |> send_error(404, "Resource Not Found")
    end
  end

  def delete(conn, %{"id" => id}) do
    case conn.status do
      nil ->
        case FactTables.delete(conn.assigns.fact_table) do
          {:ok, fact_table} ->
            conn
            |> put_status(200)
            |> render("fact_table.json", %{fact_table: fact_table})

          {:error, fact_table} ->
            error =
              case String.valid?(fact_table) do
                false -> extract_changeset_error(fact_table)
                true -> fact_table
              end

            conn
            |> send_error(400, error)
        end

      404 ->
        conn
        |> send_error(404, "Resource Not Found")
    end
  end
end
