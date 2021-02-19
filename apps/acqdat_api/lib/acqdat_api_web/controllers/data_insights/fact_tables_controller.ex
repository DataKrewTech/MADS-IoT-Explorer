defmodule AcqdatApiWeb.DataInsights.FactTablesController do
  use AcqdatApiWeb, :controller
  import AcqdatApiWeb.Helpers
  import AcqdatApiWeb.Validators.DataInsights.FactTables
  alias AcqdatApi.DataInsights.{FactTables, Topology}
  alias AcqdatApiWeb.DataInsights.FactTablesErrorHelper

  plug AcqdatApiWeb.Plug.LoadCurrentUser
  plug AcqdatApiWeb.Plug.LoadProject
  plug AcqdatApiWeb.Plug.LoadFact when action in [:update, :delete, :details, :fetch_headers]

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
        |> send_error(404, FactTablesErrorHelper.error_message(:resource_not_found))

      401 ->
        conn
        |> send_error(401, FactTablesErrorHelper.error_message(:unauthorized))
    end
  end

  def fetch_headers(conn, _params) do
    case conn.status do
      nil ->
        case FactTables.get_fact_table_headers(conn.assigns.fact_table.id) do
          {:error, message} ->
            conn
            |> send_error(404, message)

          data ->
            conn
            |> put_status(200)
            |> render("fact_table_headers.json", %{headers: data})
        end

      404 ->
        conn
        |> send_error(404, "Resource Not Found")
    end
  end

  def create(conn, params) do
    case conn.status do
      nil ->
        changeset = verify_create(params)

        with {:extract, {:ok, data}} <- {:extract, extract_changeset_data(changeset)},
             {:create, {:ok, fact_table}} <-
               {:create,
                FactTables.create(
                  data.name,
                  data.org_id,
                  conn.assigns.project,
                  conn.assigns.current_user
                )} do
          conn
          |> put_status(200)
          |> render("create.json", %{fact_table: fact_table})
        else
          {:extract, {:error, %Ecto.Changeset{} = changeset}} ->
            error = extract_changeset_error(changeset)

            conn
            |> send_error(400, error)

          {:extract, {:error, error}} ->
            send_error(conn, 400, error)

          {:create, {:error, message}} ->
            send_error(conn, 400, message)
        end

      404 ->
        conn
        |> send_error(404, FactTablesErrorHelper.error_message(:resource_not_found))

      401 ->
        conn
        |> send_error(401, FactTablesErrorHelper.error_message(:unauthorized))
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
        |> send_error(404, FactTablesErrorHelper.error_message(:resource_not_found))

      401 ->
        conn
        |> send_error(401, FactTablesErrorHelper.error_message(:unauthorized))
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
        |> send_error(404, FactTablesErrorHelper.error_message(:resource_not_found))

      401 ->
        conn
        |> send_error(401, FactTablesErrorHelper.error_message(:unauthorized))
    end
  end

  def update(conn, %{
        "org_id" => org_id,
        "project_id" => project_id,
        "id" => id,
        "user_list" => user_list,
        "date_range_settings" => date_range_settings,
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
               user_list,
               date_range_settings
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
        |> send_error(404, FactTablesErrorHelper.error_message(:resource_not_found))

      401 ->
        conn
        |> send_error(401, FactTablesErrorHelper.error_message(:unauthorized))
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
        |> send_error(404, FactTablesErrorHelper.error_message(:resource_not_found))

      401 ->
        conn
        |> send_error(401, FactTablesErrorHelper.error_message(:unauthorized))
    end
  end
end
