defmodule AcqdatApiWeb.EntityController do
  use AcqdatApiWeb, :controller
  alias AcqdatApi.EntityParser
  alias AcqdatCore.Model.Organisation, as: OrgModel
  import AcqdatApiWeb.Helpers

  plug AcqdatApiWeb.Plug.LoadOrg when action in [:update_hierarchy]

  def update_hierarchy(conn, %{"id" => org_id, "type" => type, "entities" => entities} = params) do
    case conn.status do
      nil ->
        org = conn.assigns.org

        with {:ok, data} <- EntityParser.parse(entities, org_id, nil, type, params) do
          conn |> put_status(200) |> render("organisation_tree.json", org)
        else
          {:error, message} ->
            conn
            |> put_status(404)
            |> json(%{
              "success" => false,
              "error" => true,
              "message:" => message
            })
        end

      404 ->
        conn
        |> send_error(404, "Resource Not Found")
    end
  end
end
