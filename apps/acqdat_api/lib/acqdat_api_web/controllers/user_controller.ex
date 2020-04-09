defmodule AcqdatApiWeb.UserController do
  use AcqdatApiWeb, :controller
  alias AcqdatCore.Model.User, as: UserModel
  import AcqdatApiWeb.Helpers

  plug :load_user when action in [:show]

  def show(conn, _params) do
    case conn.status do
      nil ->
        user = conn.assigns.user

        conn
        |> put_status(200)
        |> render("user_details.json", %{user_details: user})

      404 ->
        conn
        |> send_error(404, "Resource Not Found")
    end
  end

  defp load_user(%{params: %{"id" => user_id}} = conn, _params) do
    {user_id, _} = Integer.parse(user_id)

    case UserModel.get(user_id) do
      {:ok, user} ->
        assign(conn, :user, user)

      {:error, _message} ->
        conn
        |> put_status(404)
    end
  end
end
