defmodule AcqdatApiWeb.TenantManagement.RequestsController do
  use AcqdatApiWeb, :authorized_controller
  import AcqdatApiWeb.Helpers
  import AcqdatApiWeb.Validators.TenantManagement.Requests
  alias AcqdatApiWeb.TenantManagement.RequestsErrorHelper
  alias AcqdatApi.TenantManagement.Requests
  alias AcqdatApi.EntityManagement.Organisation
  alias AcqdatApiWeb.EntityManagement.OrganisationErrorHelper

  plug AcqdatApiWeb.Plug.LoadCurrentUser when action in [:update]
  plug AcqdatApiWeb.Plug.LoadRequests when action in [:update]

  def update(conn, params) do
    case conn.status do
      nil ->
        current_user = conn.assigns[:current_user]

        %{assigns: %{request: request}} = conn

        case Requests.validate(params, current_user, request) do
          {:ok, message} ->
            conn
            |> put_status(200)
            |> render("request_messg.json", message: message)

          {:error, %{error: message}} ->
            send_error(conn, 400, message)

          {:error, message} ->
            error = extract_changeset_error(message)
            send_error(conn, 400, error)
        end

      404 ->
        conn
        |> send_error(404, RequestsErrorHelper.error_message(:resource_not_found))

      401 ->
        conn
        |> send_error(401, RequestsErrorHelper.error_message(:unauthorized))
    end
  end

  def index(conn, params) do
    changeset = verify_index_params(params)

    case conn.status do
      nil ->
        {:extract, {:ok, data}} = {:extract, extract_changeset_data(changeset)}
        {:list, requests} = {:list, Requests.get_all(data)}

        conn
        |> put_status(200)
        |> render("index.json", requests)

      404 ->
        conn
        |> send_error(404, RequestsErrorHelper.error_message(:resource_not_found))

      401 ->
        conn
        |> send_error(401, RequestsErrorHelper.error_message(:unauthorized))
    end
  end

  def org_index(conn, params) do
    changeset = verify_index_params(params)

    case conn.status do
      nil ->
        {:extract, {:ok, data}} = {:extract, extract_changeset_data(changeset)}
        {:list, organisation} = {:list, Organisation.get_all(data, [:apps, :projects])}

        conn
        |> put_status(200)
        |> render("org_index.json", %{organisation: organisation})

      404 ->
        conn
        |> send_error(404, OrganisationErrorHelper.error_message(:resource_not_found))

      401 ->
        conn
        |> send_error(401, OrganisationErrorHelper.error_message(:unauthorized))
    end
  end
end
