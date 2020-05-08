defmodule AcqdatApiWeb.RoleManagement.RoleController do
  use AcqdatApiWeb, :controller
  import AcqdatApiWeb.Helpers
  import AcqdatApiWeb.Validators.RoleManagement.Role
  alias AcqdatCore.Model.RoleManagement.Role, as: RoleModel

  def index(conn, params) do
    changeset = verify_index_params(params)

    case conn.status do
      nil ->
        with {:extract, {:ok, data}} <- {:extract, extract_changeset_data(changeset)},
             {:list, role} <- {:list, RoleModel.get_all(data)} do
          conn
          |> put_status(200)
          |> render("index.json", role)
        else
          {:extract, {:error, error}} ->
            send_error(conn, 400, error)

          {:list, {:error, message}} ->
            send_error(conn, 400, message.error)
        end

      404 ->
        conn
        |> send_error(404, "Resource Not Found")
    end
  end
end
