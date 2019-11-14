defmodule AcqdatWeb.API.ErrorHandler do
  use AcqdatApiWeb, :controller

  def auth_error(conn, {type, _reason}, _opts) do
    conn
    |> put_status(401)
    |> render(AcqdatWeb.API.AuthView, "401.json", message: to_string(type))
  end
end
