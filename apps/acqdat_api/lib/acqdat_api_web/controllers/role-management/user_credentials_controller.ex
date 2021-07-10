defmodule AcqdatApiWeb.RoleManagement.UserCredentialsController do
  use AcqdatApiWeb, :authorized_controller
  alias AcqdatApiWeb.RoleManagement.UserErrorHelper
  import AcqdatApiWeb.Helpers
  import AcqdatApiWeb.Validators.RoleManagement.UserCredentials
  alias AcqdatApi.RoleManagement.UserCredentials
  alias AcqdatApi.{Image, ImageDeletion}

  plug :load_credentials when action in [:update]

  def show(conn, %{"id" => id}) do
    case conn.status do
      nil ->
        {id, _} = Integer.parse(id)

        with {:show, {:ok, user_cred}} <- {:show, UserCredentials.get(id)} do
          conn
          |> put_status(200)
          |> render("user_credentials.json", %{user_details: user_cred})
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

  def update(conn, params) do
    case conn.status do
      nil ->
        %{assigns: %{credentials: credentials}} = conn
        params = Map.put(params, "avatar", credentials.avatar)

        params = extract_image(conn, credentials, params)

        case UserCredentials.update(credentials, params) do
          {:ok, user_cred} ->
            conn
            |> put_status(200)
            |> render("user_credentials.json", %{user_details: user_cred})

          {:error, error} ->
            send_error(conn, 400, error)

          {:error, message} ->
            send_error(conn, 400, message)
        end

      404 ->
        conn
        |> send_error(404, RoleManagementErrorHelper.error_message(:resource_not_found))

      401 ->
        conn
        |> send_error(401, RoleManagementErrorHelper.error_message(:unauthorized))
    end
  end

  defp extract_image(conn, credentials, params) do
    case is_nil(params["image"]) do
      true ->
        params

      false ->
        if credentials.avatar != nil do
          ImageDeletion.delete_operation(credentials.avatar, "credentials/#{credentials.id}")
        end

        add_image_url(conn, params, credentials.id)
    end
  end

  defp add_image_url(conn, %{"image" => image} = params, entity_id) do
    scope = "credentials/#{entity_id}"

    with {:ok, image_name} <- Image.store({image, scope}) do
      Map.replace!(params, "avatar", Image.url({image_name, scope}))
    else
      {:error, error} -> send_error(conn, 400, error)
    end
  end

  defp load_credentials(%{params: %{"id" => id}} = conn, _params) do
    {id, _} = Integer.parse(id)

    case UserCredentials.get(id) do
      {:ok, credentials} ->
        assign(conn, :credentials, credentials)

      {:error, _message} ->
        conn
        |> put_status(404)
    end
  end
end
