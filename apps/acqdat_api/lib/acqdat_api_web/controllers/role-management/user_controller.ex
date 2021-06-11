defmodule AcqdatApiWeb.RoleManagement.UserController do
  use AcqdatApiWeb, :authorized_controller
  alias AcqdatApi.RoleManagement.User
  alias AcqdatCore.ElasticSearch
  alias AcqdatApi.Image
  alias AcqdatApiWeb.RoleManagement.UserErrorHelper
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
            conn
            |> send_error(400, UserErrorHelper.error_message(:resource_not_found))
        end

      404 ->
        conn
        |> send_error(404, UserErrorHelper.error_message(:resource_not_found))

      401 ->
        conn
        |> send_error(401, UserErrorHelper.error_message(:unauthorized))
    end
  end

  def create(conn, %{"org_id" => org_id} = params) do
    case conn.status do
      nil ->
        [token | _] = conn |> get_req_header("invitation-token")

        changeset =
          if params["user"] do
            user_params =
              params["user"]
              |> Map.put("token", token)
              |> Map.put("org_id", org_id)

            verify_create_params(user_params)
          else
            params =
              params
              |> Map.put("token", token)

            verify_join_org_params(params)
          end

        with {:extract, {:ok, data}} <- {:extract, extract_changeset_data(changeset)},
             {:create, {:ok, user}} <- {:create, User.create(data)} do
          # TODO: Need to implement this for elasticsearch as per new design
          # Task.start_link(fn ->
          #   ElasticSearch.create_user("organisation", user, %{id: user.org_id})
          # end)

          message =
            if params["user"] do
              "User Created Successfully"
            else
              "User has joined organisation Successfully"
            end

          conn
          |> put_status(200)
          |> render("user_creation.json", message: message)
        else
          {:extract, {:error, error}} ->
            error = extract_changeset_error(error)
            send_error(conn, 400, error)

          {:create, {:error, error}} ->
            send_error(conn, 400, UserErrorHelper.error_message(:create_user_error, error.error))
        end

      404 ->
        conn
        |> send_error(404, UserErrorHelper.error_message(:resource_not_found))

      401 ->
        conn
        |> send_error(401, UserErrorHelper.error_message(:unauthorized))
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
            |> send_error(404, UserErrorHelper.error_message(:elasticsearch, message))
        end

      404 ->
        conn
        |> send_error(404, UserErrorHelper.error_message(:resource_not_found))

      401 ->
        conn
        |> send_error(401, UserErrorHelper.error_message(:unauthorized))
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
        |> send_error(404, UserErrorHelper.error_message(:resource_not_found))

      401 ->
        conn
        |> send_error(401, UserErrorHelper.error_message(:unauthorized))
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
        |> send_error(404, UserErrorHelper.error_message(:resource_not_found))

      401 ->
        conn
        |> send_error(401, UserErrorHelper.error_message(:unauthorized))
    end
  end

  def index(conn, params) do
    case conn.status do
      nil ->
        with {:ok, hits} <- ElasticSearch.user_indexing(params) do
          conn |> put_status(200) |> render("hits.json", %{hits: hits})
        else
          {:error, message} ->
            conn
            |> send_error(404, UserErrorHelper.error_message(:elasticsearch, message))
        end

      404 ->
        conn
        |> send_error(404, UserErrorHelper.error_message(:resource_not_found))

      401 ->
        conn
        |> send_error(401, UserErrorHelper.error_message(:unauthorized))
    end
  end

  def update(conn, params) do
    case conn.status do
      nil ->
        %{assigns: %{user: user}} = conn

        case User.update_user(user, params) do
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
        |> send_error(404, UserErrorHelper.error_message(:resource_not_found))

      401 ->
        conn
        |> send_error(401, UserErrorHelper.error_message(:unauthorized))
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
        |> send_error(404, UserErrorHelper.error_message(:resource_not_found))

      401 ->
        conn
        |> send_error(401, UserErrorHelper.error_message(:unauthorized))
    end
  end
end
