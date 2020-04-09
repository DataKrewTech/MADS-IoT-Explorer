defmodule AcqdatApiWeb.UserController do
  use AcqdatApiWeb, :controller
  alias AcqdatApi.User
  import AcqdatApiWeb.Helpers

  def show(conn, %{"id" => id}) do
    case conn.status do
      nil ->
        {id, _} = Integer.parse(id)

        with {:show, {:ok, user}} <- {:show, User.get(id)} do
          conn
          |> put_status(200)
          |> render("user_details.json", %{user_details: user})
        else
          {:show, {:error, message}} ->
            send_error(conn, 400, message)
        end

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
