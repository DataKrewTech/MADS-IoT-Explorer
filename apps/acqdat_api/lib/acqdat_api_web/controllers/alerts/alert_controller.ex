defmodule AcqdatApiWeb.Alerts.AlertController do
  @moduledoc """
  Contains API related to alerts which is been created using alert rules defined for a particular entity.
  """
  use AcqdatApiWeb, :controller
  import AcqdatApiWeb.Helpers
  import AcqdatApiWeb.Validators.Alerts.Alert
  alias AcqdatApi.Alerts.Alert

  plug AcqdatApiWeb.Plug.LoadOrg
  plug AcqdatApiWeb.Plug.LoadAlert when action in [:update, :delete, :show]

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
        |> send_error(404, "Resource Not Found")
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
        |> send_error(404, "Resource Not Found")
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
        |> send_error(404, "Resource Not Found")
    end
  end
end
