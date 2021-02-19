defmodule AcqdatApiWeb.RoleManagement.UserSettingController do
  use AcqdatApiWeb, :authorized_controller
  alias AcqdatApi.RoleManagement.UserSetting
  alias AcqdatApiWeb.RoleManagement.RoleManagementErrorHelper
  import AcqdatApiWeb.Validators.RoleManagement.UserSetting
  import AcqdatApiWeb.Helpers

  plug :load_user_setting when action in [:update]

  def create(conn, params) do
    case conn.status do
      nil ->
        changeset = verify_user_setting_params(params)

        with {:extract, {:ok, data}} <- {:extract, extract_changeset_data(changeset)},
             {:create, {:ok, setting}} <- {:create, UserSetting.create(data)} do
          conn
          |> put_status(200)
          |> render("user_setting.json", %{setting: setting})
        else
          {:extract, {:error, error}} ->
            send_error(conn, 400, error)

          {:create, {:error, message}} ->
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

  def update(conn, params) do
    case conn.status do
      nil ->
        %{assigns: %{user_setting: user_setting}} = conn
        changeset = verify_user_setting_params(params)

        with {:extract, {:ok, data}} <- {:extract, extract_changeset_data(changeset)},
             {:update, {:ok, setting}} <- {:update, UserSetting.update(user_setting, data)} do
          conn
          |> put_status(200)
          |> render("user_setting.json", %{setting: setting})
        else
          {:extract, {:error, error}} ->
            send_error(conn, 400, error)

          {:update, {:error, message}} ->
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

  defp load_user_setting(%{params: %{"id" => id}} = conn, _params) do
    {id, _} = Integer.parse(id)

    case UserSetting.get(id) do
      {:ok, user_setting} ->
        assign(conn, :user_setting, user_setting)

      {:error, _message} ->
        conn
        |> put_status(404)
    end
  end
end
