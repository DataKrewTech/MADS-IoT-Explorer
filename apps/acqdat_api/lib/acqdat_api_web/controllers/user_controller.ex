defmodule AcqdatApiWeb.UserController do
  use AcqdatApiWeb, :controller
  alias AcqdatCore.Model.User, as: UserModel
  import AcqdatApiWeb.Helpers

  def show(conn, %{"id" => id}) do
    {id, _} = Integer.parse(id)

    case conn.status do
      nil ->
        {:ok, user_details} = {:ok, UserModel.get(id)}

        conn
        |> put_status(200)
        |> render("user_details.json", %{user_details: user_details})

      404 ->
        conn
        |> send_error(404, "Resource Not Found")
    end
  end
end
