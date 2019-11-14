defmodule AcqdatApiWeb.AuthController do
  use AcqdatApiWeb, :controller
  import AcqdatApiWeb.Helpers
  import AcqdatApiWeb.Validators.Auth
  alias AcqdatApi.Account

  def sign_in(conn, params) do
    changeset = verify_login_credentials(params)

    with {:extract, {:ok, data}} <- {:extract, extract_changeset_data(changeset)},
        {:login, {:ok, result}} <- {:login, Account.sign_in(data)}
      do
        conn
        |> put_status(200)
        |> render("signin.json", result)
    else
      {:extract, {:error, error}} ->
        send_error(conn, 400, error)
      {:login, {:error, message}} ->
        send_error(conn, 200, message)
    end
  end

  def refresh_token(conn, params) do
    changeset = verify_refresh_params(params)

    with {:extract, {:ok, data}} <- {:extract, extract_changeset_data(changeset)},
        {:refresh, {:ok, result}} <- {:refresh, Account.refresh_token(data)}
      do
        conn
        |> put_status(200)
        |> render("refresh.json", token: result)
    else
      {:extract, {:error, error}} ->
        send_error(conn, 400, error)
      {:refresh, {:error, message}} ->
        send_error(conn, 200, message)
    end
  end

  def sign_out(conn, params) do

  end
end
