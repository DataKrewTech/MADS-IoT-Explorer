defmodule AcqdatApiWeb.EntityManagement.OrganisationController do
  use AcqdatApiWeb, :authorized_controller
  import AcqdatApiWeb.Helpers
  import AcqdatApiWeb.Validators.EntityManagement.Organisation
  alias AcqdatApi.EntityManagement.Organisation
  alias AcqdatApiWeb.EntityManagement.OrganisationErrorHelper
  alias AcqdatCore.Model.EntityManagement.Organisation, as: OrgModel

  defdelegate get_apps(data), to: OrgModel

  plug :load_org when action in [:show, :get_apps, :update, :delete]

  def show(conn, _params) do
    case conn.status do
      nil ->
        conn
        |> put_status(200)
        |> render("org.json", %{organisation: conn.assigns.org})

      404 ->
        conn
        |> send_error(404, OrganisationErrorHelper.error_message(:resource_not_found))

      401 ->
        conn
        |> send_error(401, OrganisationErrorHelper.error_message(:unauthorized))
    end
  end

  def create(conn, params) do
    case conn.status do
      nil ->
        changeset = verify_organisation(params)

        with {:extract, {:ok, data}} <- {:extract, extract_changeset_data(changeset)},
             {:create, {:ok, organisation}} <- {:create, Organisation.create(data)} do
          conn
          |> put_status(200)
          |> render("org.json", %{organisation: organisation})
        else
          {:extract, {:error, error}} ->
            send_error(conn, 400, error)

          {:create, {:error, message}} ->
            send_error(conn, 400, message)
        end

      404 ->
        conn
        |> send_error(404, OrganisationErrorHelper.error_message(:resource_not_found))

      401 ->
        conn
        |> send_error(401, OrganisationErrorHelper.error_message(:unauthorized))
    end
  end

  def update(conn, params) do
    case conn.status do
      nil ->
        case Organisation.update(conn.assigns.org, params) do
          {:ok, organisation} ->
            conn
            |> put_status(200)
            |> render("org.json", %{organisation: organisation})

          {:error, organisation} ->
            error = extract_changeset_error(organisation)

            conn
            |> send_error(400, error)
        end

      404 ->
        conn
        |> send_error(404, OrganisationErrorHelper.error_message(:resource_not_found))

      401 ->
        conn
        |> send_error(401, OrganisationErrorHelper.error_message(:unauthorized))
    end
  end

  def index(conn, params) do
    changeset = verify_index_params(params)

    case conn.status do
      nil ->
        {:extract, {:ok, data}} = {:extract, extract_changeset_data(changeset)}
        {:list, organisation} = {:list, Organisation.get_all(data, [:apps, :projects])}

        conn
        |> put_status(200)
        |> render("index.json", %{organisation: organisation})

      404 ->
        conn
        |> send_error(404, OrganisationErrorHelper.error_message(:resource_not_found))

      401 ->
        conn
        |> send_error(401, OrganisationErrorHelper.error_message(:unauthorized))
    end
  end

  # def delete(conn, _params) do
  #   case conn.status do
  #     nil ->
  #       case Organisation.delete(conn.assigns.org) do
  #         {:ok, organisation} ->
  #           conn
  #           |> put_status(200)
  #           |> render("org.json", %{organisation: organisation})

  #         {:error, organisation} ->
  #           error = extract_changeset_error(organisation)

  #           conn
  #           |> send_error(400, error)
  #       end

  #     404 ->
  #       conn
  #       |> send_error(404, "Resource Not Found")

  #     401 ->
  #       conn
  #       |> send_error(401, "Unauthorized")
  #   end
  # end

  def get_apps(conn, _params) do
    case conn.status do
      nil ->
        org = conn.assigns.org

        with {:list, apps} <- {:list, get_apps(org)} do
          conn
          |> put_status(200)
          |> render("apps.json", %{apps: apps})
        else
          {:list, {:error, message}} ->
            send_error(conn, 400, message.error)
        end

      404 ->
        conn
        |> send_error(404, OrganisationErrorHelper.error_message(:resource_not_found))

      401 ->
        conn
        |> send_error(401, OrganisationErrorHelper.error_message(:unauthorized))
    end
  end

  defp load_org(%{params: %{"id" => org_id}} = conn, _params) do
    check_org(conn, org_id)
  end

  defp check_org(conn, org_id) do
    {org_id, _} = Integer.parse(org_id)

    case OrgModel.get_by_id(org_id) do
      {:ok, org} ->
        assign(conn, :org, org)

      {:error, _message} ->
        conn
        |> put_status(404)
    end
  end
end
