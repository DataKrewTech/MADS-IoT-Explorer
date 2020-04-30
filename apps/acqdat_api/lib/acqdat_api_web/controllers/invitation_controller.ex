defmodule AcqdatApiWeb.InvitationController do
  use AcqdatApiWeb, :controller
  alias AcqdatApi.Invitation
  import AcqdatApiWeb.Helpers
  import AcqdatApiWeb.Validators.Invitation
  alias AcqdatCore.Schema.User
  alias AcqdatCore.Model.Invitation, as: InvitationModel
  alias AcqdatCore.Repo

  plug AcqdatApiWeb.Plug.LoadOrg when action in [:create, :update, :index, :delete]
  plug AcqdatApiWeb.Plug.LoadInvitation when action in [:update, :delete]
  plug :validate_inviter when action in [:create]

  def index(conn, params) do
    changeset = verify_index_params(params)

    case conn.status do
      nil ->
        {:extract, {:ok, data}} = {:extract, extract_changeset_data(changeset)}
        {:list, sensor} = {:list, InvitationModel.get_all(data)}

        conn
        |> put_status(200)
        |> render("index.json", sensor)

      404 ->
        conn
        |> send_error(404, "Resource Not Found")
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

  def update(conn, %{"id" => id}) do
    invitation = conn.assigns[:invitation]
    current_user = Repo.get(User, Guardian.Plug.current_resource(conn))

    case conn.status do
      nil ->
        case Invitation.update(invitation, current_user) do
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

  def delete(conn, %{"id" => id}) do
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
