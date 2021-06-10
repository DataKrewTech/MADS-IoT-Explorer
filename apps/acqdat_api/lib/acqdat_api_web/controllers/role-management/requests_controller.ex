defmodule AcqdatApiWeb.RoleManagement.RequestsController do
  use AcqdatApiWeb, :authorized_controller
  import AcqdatApiWeb.Helpers
  alias AcqdatApiWeb.RoleManagement.RequestsErrorHelper
  alias AcqdatApi.RoleManagement.Requests

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
end
