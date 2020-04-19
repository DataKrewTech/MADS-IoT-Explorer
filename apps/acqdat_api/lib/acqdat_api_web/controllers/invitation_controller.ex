defmodule AcqdatApiWeb.InvitationController do
  use AcqdatApiWeb, :controller
  alias AcqdatApi.Invitation
  import AcqdatApiWeb.Helpers
  import AcqdatApiWeb.Validators.Invitation
  alias AcqdatCore.Schema.User
  alias AcqdatCore.Repo

  plug(:validate_inviter when action in [:create])

  def create(conn, %{"invitation" => invite_attrs}) do
    case conn.status do
      nil ->
        changeset = verify_create_params(invite_attrs)

        user = conn.assigns[:current_user]

        with {:extract, {:ok, data}} <- {:extract, extract_changeset_data(changeset)},
             {:invite, {:ok, message}} <- {:invite, Invitation.create(data, user)} do
          conn
          |> put_status(200)
          |> render("invite.json", message: message)
        else
          {:extract, {:error, error}} ->
            send_error(conn, 400, error)

          {:invite, {:error, message}} ->
            send_error(conn, 400, message)
        end

      404 ->
        conn
        |> send_error(404, "User already exists with this email address")
    end
  end

  defp validate_inviter(
         %{params: %{"invitation" => %{"email" => invitee_email}}} = conn,
         _params
       ) do
    user = Repo.get(User, Guardian.Plug.current_resource(conn))

    case invitee_email == user.email do
      true ->
        conn
        |> put_status(404)

      false ->
        assign(conn, :current_user, user)
    end
  end
end
