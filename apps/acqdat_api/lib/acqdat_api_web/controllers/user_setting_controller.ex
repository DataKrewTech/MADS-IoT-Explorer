defmodule AcqdatApiWeb.UserSettingController do
  use AcqdatApiWeb, :controller
  alias AcqdatApi.UserSetting
  alias AcqdatCore.Model.UserSetting, as: UserSettingModel
  import AcqdatApiWeb.Validators.UserSetting
  import AcqdatApiWeb.Helpers

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
        |> send_error(404, "Resource Not Found")
    end
  end
end
