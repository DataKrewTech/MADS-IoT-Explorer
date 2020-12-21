defmodule AcqdatApiWeb.RoleManagement.InvitationController do
  use AcqdatApiWeb, :controller
  alias AcqdatApi.RoleManagement.Invitation
  import AcqdatApiWeb.Helpers
  import AcqdatApiWeb.Validators.RoleManagement.Invitation
  alias AcqdatCore.Model.RoleManagement.Invitation, as: InvitationModel

  plug AcqdatApiWeb.Plug.LoadOrg when action in [:create, :update, :index, :delete]
  plug AcqdatApiWeb.Plug.LoadInvitation when action in [:update, :delete]
  plug AcqdatApiWeb.Plug.LoadCurrentUser when action in [:create, :update]
  plug :validate_inviter when action in [:create]

  def index(conn, params) do
    changeset = verify_index_params(params)

    case conn.status do
      nil ->
        {:extract, {:ok, data}} = {:extract, extract_changeset_data(changeset)}
        {:list, invitations} = {:list, InvitationModel.get_all(data)}

        conn
        |> put_status(200)
        |> render("index.json", invitations)

      404 ->
        conn
        |> send_error(404, "Resource Not Found")
    end
  end

  def validate_token(conn, %{"token" => token}) do
    case conn.status do
      nil ->
        case Invitation.get_by_token(token) do
          nil ->
            conn
            |> put_status(200)
            |> json(%{is_valid: false})

          _token_details ->
            conn
            |> put_status(200)
            |> json(%{is_valid: true})
        end

      404 ->
        conn
        |> send_error(404, "User already exists with this email address")
    end
  end

  def create(conn, %{"invitation" => invite_attrs, "org_id" => org_id}) do
    case conn.status do
      nil ->
        invite_attrs =
          invite_attrs
          |> Map.put("org_id", org_id)

        changeset = verify_create_params(invite_attrs)

        current_user = conn.assigns[:current_user]

        with {:extract, {:ok, data}} <- {:extract, extract_changeset_data(changeset)},
             {:invite, {:ok, message}} <- {:invite, Invitation.create(data, current_user)} do
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

  def update(conn, _params) do
    invitation = conn.assigns[:invitation]

    case conn.status do
      nil ->
        case Invitation.update(invitation, conn.assigns.current_user) do
          {:ok, message} ->
            conn
            |> put_status(200)
            |> render("invite.json", %{message: message})

          {:error, error} ->
            conn
            |> send_error(400, error)
        end

      404 ->
        conn
        |> send_error(404, "Resource Not Found")
    end
  end

  def delete(conn, _params) do
    invitation = conn.assigns[:invitation]

    case conn.status do
      nil ->
        case Invitation.delete(invitation) do
          {:ok, message} ->
            conn
            |> put_status(200)
            |> render("invite.json", %{message: message})

          {:error, error} ->
            conn
            |> send_error(400, error)
        end

      404 ->
        conn
        |> send_error(404, "Resource Not Found")
    end
  end

  defp validate_inviter(
         %{params: %{"invitation" => %{"email" => invitee_email}}} = conn,
         _params
       ) do
    user = conn.assigns.current_user

    case invitee_email == user.email do
      true ->
        conn
        |> put_status(404)

      false ->
        assign(conn, :current_user, user)
    end
  end
end
