defmodule AcqdatApiWeb.RoleManagement.UserGroupController do
  use AcqdatApiWeb, :authorized_controller
  alias AcqdatApi.ApiAccess.UserGroup
  import AcqdatApiWeb.Helpers
  import AcqdatApiWeb.Validators.ApiAccess.UserGroup

  plug :load_group when action in [:update, :delete]

  def create(conn, params) do
    case conn.status do
      nil ->
        changeset = verify_group(params)

        with {:extract, {:ok, data}} <- {:extract, extract_changeset_data(changeset)},
             {:create, {:ok, group}} <- {:create, UserGroup.create(data)} do
          conn
          |> put_status(200)
          |> render("user_group.json", %{group: group})
        else
          {:extract, {:error, error}} ->
            send_error(conn, 400, error)

          {:create, {:error, message}} ->
            send_error(conn, 400, message)
        end

      404 ->
        conn
        |> send_error(404, "Resource Not Found")

      401 ->
        conn
        |> send_error(401, "Unauthorized")
    end
  end

  def update(conn, params) do
    case conn.status do
      nil ->
        case UserGroup.update(conn.assigns.group, params) do
          {:ok, group} ->
            conn
            |> put_status(200)
            |> render("user_group.json", %{group: group})

          {:error, group} ->
            error = extract_changeset_error(group)

            conn
            |> send_error(400, error)
        end

      404 ->
        conn
        |> send_error(404, "Resource Not Found")

      401 ->
        conn
        |> send_error(401, "Unauthorized")
    end
  end

  def index(conn, params) do
    changeset = verify_index_params(params)

    case conn.status do
      nil ->
        {:extract, {:ok, data}} = {:extract, extract_changeset_data(changeset)}
        {:list, group} = {:list, UserGroup.get_all(data, [:policies])}

        conn
        |> put_status(200)
        |> render("index.json", group)

      404 ->
        conn
        |> send_error(404, "Resource Not Found")

      401 ->
        conn
        |> send_error(401, "Unauthorized")
    end
  end

  def group_policies(conn, params) do
    changeset = verify_group_policies_params(params)

    case conn.status do
      nil ->
        {:extract, {:ok, data}} = {:extract, extract_changeset_data(changeset)}
        {:list, group} = {:list, UserGroup.return_policies(data, [:policies])}

        conn
        |> put_status(200)
        |> render("index_policies.json", group)

      404 ->
        conn
        |> send_error(404, "Resource Not Found")

      401 ->
        conn
        |> send_error(401, "Unauthorized")
    end
  end

  def delete(conn, _params) do
    case conn.status do
      nil ->
        case UserGroup.delete(conn.assigns.group) do
          {:ok, group} ->
            conn
            |> put_status(200)
            |> render("user_group.json", %{group: group})

          {:error, message} ->
            error = extract_changeset_error(message)

            conn
            |> send_error(400, error)
        end

      404 ->
        conn
        |> send_error(404, "Resource Not Found")

      401 ->
        conn
        |> send_error(401, "Unauthorized")
    end
  end

  defp load_group(%{params: %{"id" => id}} = conn, _params) do
    {id, _} = Integer.parse(id)

    case UserGroup.get(id) do
      {:ok, group} ->
        assign(conn, :group, group)

      {:error, _message} ->
        conn
        |> put_status(404)
    end
  end
end
