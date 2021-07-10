defmodule AcqdatApiWeb.RoleManagement.ForgotPasswordController do
  use AcqdatApiWeb, :controller
  import AcqdatApiWeb.Helpers
  import AcqdatApiWeb.Validators.RoleManagement.ForgotPassword
  alias AcqdatApiWeb.RoleManagement.RoleManagementErrorHelper
  alias AcqdatApi.RoleManagement.ForgotPassword, as: ForgotPassword

  def forgot_password(conn, params) do
    changeset = verify_email(params)

    case conn.status do
      nil ->
        with {:extract, {:ok, data}} <- {:extract, extract_changeset_data(changeset)},
             {:list, {:ok, _url}} <- {:list, ForgotPassword.create(data)} do
          conn
          |> put_status(200)
          |> json(RoleManagementErrorHelper.confirm_message(:mail_sent))
        else
          {:extract, {:error, error}} ->
            conn
            |> put_status(400)
            |> json(RoleManagementErrorHelper.error_message(:forgot_password, error))

          {:list, {:error, message}} ->
            conn
            |> put_status(400)
            |> json(RoleManagementErrorHelper.error_message(:forgot_password, message))
        end

      404 ->
        conn
        |> send_error(404, RoleManagementErrorHelper.error_message(:wrong_email))
    end
  end

  def reset_password(conn, params) do
    case conn.status do
      nil ->
        user = conn.assigns.user

        case ForgotPassword.update(user, params) do
          {:ok, _user} ->
            Task.start_link(fn ->
              ForgotPassword.delete(user.id)
            end)

            conn
            |> put_status(200)
            |> json(RoleManagementErrorHelper.confirm_message(:reset_success))

          {:error, message} ->
            error = extract_changeset_error(message)
            send_error(conn, 400, error)

          nil ->
            conn
            |> send_error(401, RoleManagementErrorHelper.error_message(:unauthorized_link))
        end

      401 ->
        conn
        |> send_error(401, RoleManagementErrorHelper.error_message(:unauthorized_link))
    end
  end
end
