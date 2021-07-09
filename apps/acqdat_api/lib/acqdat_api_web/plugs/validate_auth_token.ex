defmodule AcqdatApiWeb.Plug.ValidateAuthToken do
  import Plug.Conn
  import AcqdatApiWeb.Helpers
  alias AcqdatApiWeb.AuthErrorHelper
  alias AcqdatApiWeb.Guardian

  @spec init(any) :: any
  def init(default), do: default

  @spec call(Plug.Conn.t(), any) :: Plug.Conn.t()
  def call(conn, _params) do
    [token | _] = conn |> get_req_header("auth-token")

    token
    |> Guardian.decode_and_verify()
    |> validate_token_res(conn)
  end

  defp validate_token_res({:ok, %{"sub" => credential_id}}, conn) do
    assign(conn, :credential_id, credential_id)
  end

  defp validate_token_res({:error, _}, conn) do
    conn
    |> send_error(401, AuthErrorHelper.error_message(:unauthorized))
    |> halt
  end
end
