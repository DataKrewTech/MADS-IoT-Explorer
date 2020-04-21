defmodule AcqdatApiWeb.AuthController do
  use AcqdatApiWeb, :controller
  import AcqdatApiWeb.Helpers
  import AcqdatApiWeb.Validators.Auth
  alias AcqdatApi.Account

  def sign_in(conn, params) do
    changeset = verify_login_credentials(params)

    with {:extract, {:ok, data}} <- {:extract, extract_changeset_data(changeset)},
         {:login, {:ok, result}} <- {:login, Account.sign_in(data)} do
      conn
      |> put_status(200)
      |> render("signin.json", result)
    else
      {:extract, {:error, error}} ->
        send_error(conn, 400, error)

      {:login, {:error, message}} ->
        send_error(conn, 401, message)
    end
  end

  def validate_token(conn, params) do
    changeset = verify_refresh_params(params)
    refresh_token = AcqdatApiWeb.Guardian.Plug.current_token(conn)

    with {:extract, {:ok, data}} <- {:extract, extract_changeset_data(changeset)},
         {:refresh, {:ok, result}} <-
           {:refresh, Account.validate_token(Map.put(data, :refresh_token, refresh_token))} do
      conn
      |> put_status(200)
      |> render("validate_token.json", token: result)
    else
      {:extract, {:error, error}} ->
        send_error(conn, 400, error)

      {:refresh, {:error, message}} ->
        send_error(conn, 400, message)
    end
  end

  def sign_out(conn, params) do
    changeset = verify_sign_out_params(params)

    with {:extract, {:ok, data}} <- {:extract, extract_changeset_data(changeset)},
         {:signout, {:ok, message}} <- {:signout, Account.sign_out(data)} do
      conn
      |> put_status(200)
      |> render("signout.json", message: message)
    else
      {:extract, {:error, error}} ->
        send_error(conn, 400, error)

      {:signout, {:error, message}} ->
        send_error(conn, 400, message)
    end
  end
end
