defmodule AcqdatApiWeb.DataCruncher.EntityController do
  use AcqdatApiWeb, :controller
  import AcqdatApiWeb.Helpers

  plug AcqdatApiWeb.Plug.LoadCurrentUser
  plug AcqdatApiWeb.Plug.LoadOrg

  @secret_key_base Application.get_env(:acqdat_api, AcqdatApiWeb.Endpoint)[:secret_key_base]

  def fetch_token(conn, _params) do
    case conn.status do
      nil ->
        token =
          Phoenix.Token.sign(conn, @secret_key_base, %{
            user_id: conn.assigns.current_user.id,
            org_id: conn.assigns.org.id
          })

        conn
        |> put_status(200)
        |> render("valid_token.json", token: token)

      404 ->
        conn
        |> send_error(404, "Resource Not Found")
    end
  end
end
