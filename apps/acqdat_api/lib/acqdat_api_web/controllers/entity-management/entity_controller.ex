defmodule AcqdatApiWeb.EntityManagement.EntityController do
  use AcqdatApiWeb, :authorized_controller
  alias AcqdatApi.EntityManagement.EntityParser
  alias AcqdatCore.Model.EntityManagement.Organisation, as: OrgModel
  alias AcqdatApiWeb.EntityManagement.EntityErrorHelper
  import AcqdatApiWeb.Helpers

  plug AcqdatApiWeb.Plug.LoadCurrentUser when action in [:update_hierarchy]
  plug AcqdatApiWeb.Plug.LoadOrg when action in [:update_hierarchy]
  plug AcqdatApiWeb.Plug.LoadProject when action in [:update_hierarchy]
  plug :load_hierarchy_tree when action in [:fetch_hierarchy, :update_hierarchy]

  def update_hierarchy(conn, params) do
    case conn.status do
      nil ->
        with {:update, {:ok, _data}} <-
               {:update,
                EntityParser.update_project_hierarchy(
                  conn.assigns.current_user,
                  conn.assigns.project,
                  params
                )} do
          conn
          |> put_status(200)
          |> render("organisation_tree.json", conn.assigns.org)
        else
          {:update, {:error, message}} ->
            response =
              case is_map(message.error) do
                false -> message
                true -> message.error
              end

            send_error(conn, 400, response)
        end

      404 ->
        conn
        |> send_error(404, EntityErrorHelper.error_message(:resource_not_found))

      401 ->
        conn
        |> send_error(401, EntityErrorHelper.error_message(:unauthorized))
    end
  end

  def fetch_hierarchy(conn, _params) do
    case conn.status do
      nil ->
        org = conn.assigns.org

        conn
        |> put_status(200)
        |> render("organisation_tree.json", org)

      404 ->
        conn
        |> send_error(404, EntityErrorHelper.error_message(:resource_not_found))

      401 ->
        conn
        |> send_error(401, EntityErrorHelper.error_message(:unauthorized))
    end
  end

  def fetch_all_hierarchy(conn, %{"org_id" => org_id}) do
    case conn.status do
      nil ->
        {org_id, _} = Integer.parse(org_id)

        case OrgModel.fetch_hierarchy_by_all_projects(org_id) do
          {:ok, org} ->
            conn
            |> put_status(200)
            |> render("organisation_tree.json", %{org: org})

          {:error, _message} ->
            conn
            |> send_error(404, EntityErrorHelper.error_message(:resource_not_found))
        end

      404 ->
        conn
        |> send_error(404, EntityErrorHelper.error_message(:resource_not_found))

      401 ->
        conn
        |> send_error(401, EntityErrorHelper.error_message(:unauthorized))
    end
  end

  def fetch_count(conn, %{"type" => entity} = params) do
    # name_convention = "Elixir.AcqdatCore.Model.EntityManagement." <> entity
    # module_name = String.to_atom(name_convention)
    try do
      case entity == "ProjectArchived" or entity == "UserInvite" do
        true ->
          if entity == "ProjectArchived" do
            case EntityParser.return_archived_count() do
              nil ->
                conn
                |> put_status(200)
                |> json(%{"count" => 0})

              count ->
                conn
                |> put_status(200)
                |> json(%{"count" => count})
            end
          else
            case EntityParser.return_invite_count() do
              nil ->
                conn
                |> put_status(200)
                |> json(%{"count" => 0})

              count ->
                conn
                |> put_status(200)
                |> json(%{"count" => count})
            end
          end

        false ->
          {:ok, module_name} = ModuleEnum.dump(entity)

          case module_name.return_count() do
            nil ->
              conn
              |> put_status(200)
              |> json(%{"count" => 0})

            count ->
              conn
              |> put_status(200)
              |> json(%{"count" => count})
          end
      end
    rescue
      e in Ecto.ChangeError ->
        conn
        |> put_status(400)
        |> json(%{"message" => e.message})
    end
  end

  defp load_hierarchy_tree(
         %{params: %{"org_id" => org_id, "project_id" => project_id}} = conn,
         _params
       ) do
    check_org(conn, org_id, project_id)
  end

  defp check_org(conn, org_id, project_id) do
    {org_id, _} = Integer.parse(org_id)
    {project_id, _} = Integer.parse(project_id)

    case OrgModel.get(org_id, project_id) do
      {:ok, org} ->
        assign(conn, :org, org)

      {:error, _message} ->
        conn
        |> put_status(404)
    end
  end
end
