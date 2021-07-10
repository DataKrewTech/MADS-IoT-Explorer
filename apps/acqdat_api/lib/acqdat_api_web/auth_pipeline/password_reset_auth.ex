defmodule AcqdatApiWeb.PasswordResetAuth do
  import Plug.Conn

  alias AcqdatCore.Model.RoleManagement.ForgotPassword, as: FEModel

  @spec init(any) :: any
  def init(default), do: default

  def call(conn, _params) do
    token =
      case Map.has_key?(conn.params, "token") do
        true ->
          %{params: %{"token" => token}} = conn
          token

        false ->
          [token] =
            conn
            |> get_req_header("authorization")

          token |> String.trim("Bearer") |> String.trim(" ")
      end

    verify_token(conn, FEModel.verify_token(token))
  end

  defp verify_token(conn, {:error, _message}) do
    conn
    |> put_status(401)
  end

  defp verify_token(conn, {:ok, user}) do
    assign(conn, :user, user)
  end
end
