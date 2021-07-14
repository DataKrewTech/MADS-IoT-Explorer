defmodule AcqdatApiWeb.Alerts.AlertController do
  @moduledoc """
  Contains API related to alerts which is been created using alert rules defined for a particular entity.
  """
  use AcqdatApiWeb, :authorized_controller
  import AcqdatApiWeb.Helpers
  import AcqdatApiWeb.Validators.Alerts.Alert
  alias AcqdatApi.Alerts.Alert
  alias AcqdatCore.ElasticSearch
  alias AcqdatApiWeb.Alerts.AlertErrorHelper

  plug AcqdatApiWeb.Plug.LoadOrg
  plug AcqdatApiWeb.Plug.LoadAlert when action in [:update, :delete, :show]
  plug :put_view, AcqdatApiWeb.EntityManagement.ProjectView when action in [:fetch_projects]

  def update(conn, params) do
    case conn.status do
      nil ->
        %{assigns: %{alert: alert}} = conn

        case Alert.update(alert, params) do
          {:ok, alert} ->
            conn
            |> put_status(200)
            |> render("alert.json", %{alert: alert})

          {:error, alert} ->
            error = extract_changeset_error(alert)

            conn
            |> send_error(400, error)
        end

      404 ->
        conn
        |> send_error(404, AlertErrorHelper.error_message(:resource_not_found))

      401 ->
        conn
        |> send_error(401, AlertErrorHelper.error_message(:unauthorized))
    end
  end

  def fetch_projects(conn, params) do
    case conn.status do
      nil ->
        with {:ok, hits} <- ElasticSearch.project_indexing(params) do
          conn |> put_status(200) |> render("hits.json", %{hits: hits})
        else
          {:error, message} ->
            conn
            |> send_error(404, AlertErrorHelper.error_message(:elasticsearch, message))
        end

      404 ->
        conn
        |> send_error(404, AlertErrorHelper.error_message(:resource_not_found))

      401 ->
        conn
        |> send_error(401, AlertErrorHelper.error_message(:unauthorized))
    end
  end

  def delete(conn, _params) do
    case conn.status do
      nil ->
        %{assigns: %{alert: alert}} = conn

        case Alert.delete(alert) do
          {:ok, alert} ->
            conn
            |> put_status(200)
            |> render("alert.json", %{alert: alert})

          {:error, alert} ->
            error = extract_changeset_error(alert)

            conn
            |> send_error(400, error)
        end

      404 ->
        conn
        |> send_error(404, AlertErrorHelper.error_message(:resource_not_found))

      401 ->
        conn
        |> send_error(401, AlertErrorHelper.error_message(:unauthorized))
    end
  end

  def index(conn, params) do
    changeset = verify_index_params(params)

    case conn.status do
      nil ->
        {:extract, {:ok, data}} = {:extract, extract_changeset_data(changeset)}
        {:list, alert} = {:list, Alert.get_all(data, params)}

        conn
        |> put_status(200)
        |> render("index.json", alert)

      404 ->
        conn
        |> send_error(404, AlertErrorHelper.error_message(:resource_not_found))

      401 ->
        conn
        |> send_error(401, AlertErrorHelper.error_message(:unauthorized))
    end
  end
end
