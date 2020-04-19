defmodule AcqdatApiWeb.RoleController do
  use AcqdatApiWeb, :controller
  import AcqdatApiWeb.Helpers
  import AcqdatApiWeb.Validators.Role
  alias AcqdatCore.Model.Role, as: RoleModel

  def index(conn, params) do
    changeset = verify_index_params(params)

    case conn.status do
      nil ->
        {:extract, {:ok, data}} = {:extract, extract_changeset_data(changeset)}
        {:list, role} = {:list, RoleModel.get_all(data)}

        conn
        |> put_status(200)
        |> render("index.json", role)

      404 ->
        conn
        |> send_error(404, "Resource Not Found")
    end
  end
end
