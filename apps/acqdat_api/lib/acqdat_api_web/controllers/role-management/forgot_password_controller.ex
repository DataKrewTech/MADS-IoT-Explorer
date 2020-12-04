defmodule AcqdatApiWeb.RoleManagement.ForgotPasswordController do
  use AcqdatApiWeb, :controller
  import AcqdatApiWeb.Helpers
  import AcqdatApiWeb.Validators.RoleManagement.ForgotPassword
  alias AcqdatApi.RoleManagement.ForgotPassword, as: ForgotPassword

  def forgot_password(conn, params) do
    changeset = verify_email(params)

    case conn.status do
      nil ->
        with {:extract, {:ok, data}} <- {:extract, extract_changeset_data(changeset)},
             {:list, {:ok, _url}} <- {:list, ForgotPassword.create(data)} do
          conn
          |> put_status(200)
          |> json(%{
            "status_code" => 200,
            "details" => "Password reset email sent.",
            "error" => "None"
          })
        else
          {:extract, {:error, error}} ->
            conn
            |> put_status(200)
            |> json(%{
              "status_code" => 400,
              "details" => error,
              "error" => error
            })

          {:list, {:error, message}} ->
            conn
            |> put_status(200)
            |> json(%{
              "status_code" => 400,
              "details" => message,
              "error" => message
            })
        end

      404 ->
        conn
        |> send_error(404, "Resource Not Found")
    end
  end

  def reset_password(conn, params) do
    case conn.status do
      nil ->
        user = conn.assigns.user

        case ForgotPassword.update_user(user, params) do
          {:ok, _user} ->
            Task.start_link(fn ->
              ForgotPassword.delete(user.id)
            end)

            conn
            |> put_status(200)
            |> json(%{
              "status_code" => 200,
              "details" => "Password reset successfully.",
              "error" => "None"
            })

          {:error, message} ->
            send_error(conn, 400, message)

          nil ->
            conn
            |> send_error(401, "Unauthorized link")
        end

      401 ->
        conn
        |> send_error(401, "Unauthorized link")
    end
  end
end
