defmodule AcqdatApiWeb.RoleManagement.UserController do
  use AcqdatApiWeb, :controller
  alias AcqdatApi.RoleManagement.User
  alias AcqdatApi.ElasticSearch
  alias AcqdatApi.Image
  import AcqdatApiWeb.Helpers
  import AcqdatApiWeb.Validators.RoleManagement.User

  plug AcqdatApiWeb.Plug.LoadOrg when action in [:search_users, :index]

  plug AcqdatApiWeb.Plug.LoadUser
       when action in [:show, :update, :assets, :apps, :delete]

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

  def create(conn, %{"user" => user_params, "org_id" => org_id}) do
    case conn.status do
      nil ->
        [token | _] = conn |> get_req_header("invitation-token")

        user_params =
          user_params
          |> Map.put("token", token)
          |> Map.put("org_id", org_id)

        changeset = verify_create_params(user_params)

        with {:extract, {:ok, data}} <- {:extract, extract_changeset_data(changeset)},
             {:create, {:ok, user}} <- {:create, User.create(data)} do
          Task.start_link(fn ->
            ElasticSearch.create_user("organisation", user, %{id: user.org_id})
          end)

          conn
          |> put_status(200)
          |> render("user_details_without_user_setting.json", %{user_details: user})
        else
          {:extract, {:error, error}} ->
            send_error(conn, 400, error)

          {:create, {:error, error}} ->
            send_error(conn, 400, error)
        end

      404 ->
        conn
        |> send_error(404, "Resource Not Found")
    end
  end

  def search_users(conn, params) do
    case conn.status do
      nil ->
        with {:ok, hits} <- ElasticSearch.search_user(params) do
          conn |> put_status(200) |> render("hits.json", %{hits: hits})
        else
          {:error, message} ->
            conn
            |> put_status(404)
            |> json(%{
              "status_code" => 404,
              "title" => message,
              "detail" => message
            })
        end

      404 ->
        conn
        |> send_error(404, "Resource Not Found")
    end
  end

  def assets(conn, params) do
    case conn.status do
      nil ->
        %{assigns: %{user: user}} = conn

        changeset = verify_assets_params(params)

        with {:extract, {:ok, data}} <- {:extract, extract_changeset_data(changeset)},
             {:done, {:ok, user}} <- {:done, User.set_asset(user, data)} do
          conn
          |> put_status(200)
          |> render("user_assets.json", %{user: user})
        else
          {:extract, {:error, error}} ->
            send_error(conn, 400, error)

          {:create, {:error, message}} ->
            send_error(conn, 400, message)
        end

      404 ->
        conn
        |> send_error(404, "Resource Not Found")
    end
  end

  def apps(conn, params) do
    case conn.status do
      nil ->
        %{assigns: %{user: user}} = conn

        changeset = verify_apps_params(params)

        with {:extract, {:ok, data}} <- {:extract, extract_changeset_data(changeset)},
             {:done, {:ok, user}} <- {:done, User.set_apps(user, data)} do
          conn
          |> put_status(200)
          |> render("user_apps.json", %{user: user})
        else
          {:extract, {:error, error}} ->
            send_error(conn, 400, error)

          {:done, {:error, message}} ->
            send_error(conn, 400, message)
        end

      404 ->
        conn
        |> send_error(404, "Resource Not Found")
    end
  end

  def index(conn, params) do
    case conn.status do
      nil ->
        with {:ok, hits} <- ElasticSearch.user_indexing(params) do
          conn |> put_status(200) |> render("hits.json", %{hits: hits})
        else
          {:error, _message} ->
            conn
            |> put_status(404)
            |> json(%{
              "success" => false,
              "error" => true,
              "message" => "elasticsearch is not running"
            })
        end

      404 ->
        conn
        |> send_error(404, "Resource Not Found")
    end
  end

  # def index(conn, params) do
  #   changeset = verify_index_params(params)

  #   case conn.status do
  #     nil ->
  #       {:extract, {:ok, data}} = {:extract, extract_changeset_data(changeset)}
  #       {:list, user} = {:list, User.get_all(data, [:org, :role, :user_setting])}

  #       conn
  #       |> put_status(200)
  #       |> render("index.json", user)

  #     404 ->
  #       conn
  #       |> send_error(404, "Resource Not Found")
  #   end
  # end

  def update(conn, params) do
    case conn.status do
      nil ->
        %{assigns: %{user: user}} = conn

        case User.update_user(user, add_avatar_to_params(conn, params)) do
          {:ok, user} ->
            ElasticSearch.update_users("organisation", user, user.org)

            conn
            |> put_status(200)
            |> render("user_details.json", %{user_details: user})

          {:error, user} ->
            error = extract_changeset_error(user)

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
        case User.delete(conn.assigns.user) do
          {:ok, user} ->
            ElasticSearch.delete_users("organisation", user)

            conn
            |> put_status(200)
            |> render("user_details.json", %{user_details: user})

          {:error, message} ->
            error = extract_changeset_error(message)

            conn
            |> send_error(400, error)
        end

      404 ->
        conn
        |> send_error(404, "Resource Not Found")
    end
  end

  defp add_avatar_to_params(conn, params) do
    %{assigns: %{user: user}} = conn

    params = Map.put(params, "avatar", user.avatar)

    case is_nil(params["image"]) do
      true ->
        params

      false ->
        add_image_url(conn, params)
    end
  end

  defp add_image_url(conn, %{"image" => image} = params) do
    with {:ok, image_name} <- Image.store({image, "user"}) do
      Map.replace!(params, "avatar", Image.url({image_name, "user"}))
    else
      {:error, error} -> send_error(conn, 400, error)
    end
  end
end
