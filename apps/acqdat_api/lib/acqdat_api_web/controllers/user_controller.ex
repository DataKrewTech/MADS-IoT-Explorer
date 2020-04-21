defmodule AcqdatApiWeb.UserController do
  use AcqdatApiWeb, :controller
  alias AcqdatApi.User
  alias AcqdatCore.Model.Organisation, as: OrgModel
  alias AcqdatCore.Model.User, as: UserModel
  alias AcqdatApi.ElasticSearch
  import AcqdatApiWeb.Helpers

  plug :load_org when action in [:search_users, :index_users]
  plug :load_user when action in [:show]

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

  def search_users(conn, %{"label" => label}) do
    case conn.status do
      nil ->
        with {:ok, hits} <- ElasticSearch.search_user("users", label, 3),
             do: conn |> put_status(200) |> render("hits.json", %{hits: hits})

      404 ->
        conn
        |> send_error(404, "Resource Not Found")
    end
  end

  def index_users(conn, %{"page_size" => page_size}) do
    with {:ok, hits} <- ElasticSearch.user_indexing(page_size),
         do: conn |> put_status(200) |> render("index_hits.json", %{hits: hits})
  end

  defp load_org(%{params: %{"organisation_id" => org_id}} = conn, params) do
    {org_id, _} = Integer.parse(org_id)

    case OrgModel.get(org_id) do
      {:ok, org} ->
        assign(conn, :organisation, org)

      {:error, _message} ->
        conn
        |> put_status(404)
    end
  end

  defp load_user(%{params: %{"id" => id}} = conn, _params) do
    {id, _} = Integer.parse(id)

    case UserModel.get(id) do
      {:ok, user} ->
        assign(conn, :user, user)

      {:error, _message} ->
        conn
        |> put_status(404)
    end
  end
end
