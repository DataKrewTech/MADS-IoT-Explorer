defmodule AcqdatApiWeb.InvitationController do
  use AcqdatApiWeb, :controller
  alias AcqdatApi.Invitation
  import AcqdatApiWeb.Helpers
  import AcqdatApiWeb.Validators.Invitation
  # TODO: remove below alias and import, after current_user logic is implemented
  alias AcqdatCore.Schema.User
  alias AcqdatCore.Repo
  import Ecto.Query

  plug :validate_inviter when action in [:create]

  def create(conn, %{"invitation" => invite_attrs}) do
    case conn.status do
      nil ->
        changeset = verify_invitation_params(invite_attrs)

        with {:extract, {:ok, data}} <- {:extract, extract_changeset_data(changeset)},
             {:invite, {:ok, message}} <- {:invite, Invitation.create(data)} do
          conn
          |> put_status(200)
          |> render("invite.json", message: message)
        else
          {:extract, {:error, error}} ->
            send_error(conn, 400, error)

          {:create, {:error, message}} ->
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
    # TODO: Need to maintain session and gets current_user from there
    current_user = Repo.get(User, 1)

    case invitee_email == current_user.email do
      true ->
        conn
        |> put_status(404)

      false ->
        conn
    end
  end
end
