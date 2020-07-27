defmodule AcqdatApiWeb.IotManager.GatewayController do
  use AcqdatApiWeb, :controller
  alias AcqdatApi.IotManager.Gateway
  alias AcqdatApi.Image
  alias AcqdatCore.Model.IotManager.Gateway, as: GModel
  alias AcqdatCore.Model.EntityManagement.Organisation, as: OrgModel
  alias AcqdatApi.ImageDeletion
  alias AcqdatCore.Model.IotManager.GatewayDataDump
  import AcqdatApiWeb.Helpers
  import AcqdatApiWeb.Validators.IotManager.Gateway

  plug AcqdatApiWeb.Plug.LoadOrg
  plug AcqdatApiWeb.Plug.LoadProject
  plug AcqdatApiWeb.Plug.LoadGateway when action in [:update, :delete, :show, :store_commands]
  plug :load_hierarchy_tree when action in [:hierarchy]

  def index(conn, params) do
    changeset = verify_index_params(params)

    case conn.status do
      nil ->
        {:extract, {:ok, data}} = {:extract, extract_changeset_data(changeset)}
        {:list, gateway} = {:list, Gateway.get_all(data, [:org, :project])}

        conn
        |> put_status(200)
        |> render("index.json", gateway)

      404 ->
        conn
        |> send_error(404, "Resource Not Found")
    end
  end

  def update(conn, params) do
    case conn.status do
      nil ->
        %{assigns: %{gateway: gateway}} = conn
        params = Map.put(params, "image_url", gateway.image_url)

        params = extract_image(conn, gateway, params)

        case Gateway.update(gateway, params) do
          {:ok, gateway} ->
            conn
            |> put_status(200)
            |> render("show.json", %{gateway: gateway})

          {:error, error} ->
            conn
            |> send_error(400, error)
        end

      404 ->
        conn
        |> send_error(404, "Resource Not Found")
    end
  end

  def create(conn, params) do
    case conn.status do
      nil ->
        params = add_image_to_params(conn, params)
        changeset = verify_gateway(params)

        with {:extract, {:ok, data}} <- {:extract, extract_changeset_data(changeset)},
             {:create, {:ok, gateway}} <- {:create, Gateway.create(data)} do
          conn
          |> put_status(200)
          |> render("show.json", %{gateway: gateway})
        else
          {:extract, {:error, error}} ->
            send_error(conn, 400, error)

          {:create, {:error, message}} ->
            send_error(conn, 400, message)
        end

      404 ->
        conn
        |> send_error(404, "Resource Not Found")
    end
  end

  def show(conn, _params) do
    case conn.status do
      nil ->
        gateway = conn.assigns.gateway
        gateway = Gateway.load_associations(gateway)
        conn
        |> put_status(200)
        |> render("show.json", %{gateway: gateway})
      404 ->
        conn
        |> send_error(404, "Resource not found")
    end
  end

  def hierarchy(conn, _params) do
    case conn.status do
      nil ->
        org = conn.assigns.org

        conn
        |> put_status(200)
        |> render("organisation_tree.json", org)

      404 ->
        conn
        |> send_error(404, "Resource Not Found")
    end
  end

  def delete(conn, _params) do
    case conn.status do
      nil ->
        %{assigns: %{gateway: gateway}} = conn

        case Gateway.delete(gateway) do
          {:ok, gateway} ->
            gateway = Map.put(gateway, :image_url, gateway.image_url)

            if gateway.image_url do
              ImageDeletion.delete_operation(gateway, "gateway")
            end

            conn
            |> put_status(200)
            |> render("delete.json", %{gateway: gateway})

          {:error, gateway} ->
            error = extract_changeset_error(gateway)

            conn
            |> send_error(400, error)
        end

      404 ->
        conn
        |> send_error(404, "Resource Not Found")
    end
  end

  def store_commands(conn, params) do
    case conn.status do
      nil ->
        gateway = conn.asssigns.gateway
        channel = conn.assigns.gateway.channel
        Gateway.setup_command(gateway, channel, params)

        conn
        |> put_status(200)
        |> json(%{"command_set" => true})

      404 ->
        conn
        |> send_error(404, "Resource Not Found")
    end
  end

  defp add_image_to_params(conn, params) do
    params = Map.put(params, "image_url", "")

    case is_nil(params["image"]) do
      true ->
        params

      false ->
        add_image_url(conn, params)
    end
  end

  defp extract_image(conn, gateway, params) do
    case is_nil(params["image"]) do
      true ->
        params

      false ->
        ImageDeletion.delete_operation(gateway, "gateway")
        add_image_url(conn, params)
    end
  end

  defp add_image_url(conn, %{"image" => image} = params) do
    with {:ok, image_name} <- Image.store({image, "gateway"}) do
      Map.replace!(params, "image_url", Image.url({image_name, "gateway"}))
    else
      {:error, error} -> send_error(conn, 400, error)
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
        org = GModel.fetch_hierarchy_data(org, org_id, project_id)
        assign(conn, :org, org)

      {:error, _message} ->
        conn
        |> put_status(404)
    end
  end

  def data_dump_index(conn, params) do
    changeset = verify_index_params(params)

    case conn.status do
      nil ->
        {:extract, {:ok, data}} = {:extract, extract_changeset_data(changeset)}
        {:list, data_dump} = {:list, GatewayDataDump.get_all(data, [:org, :project])}

        conn
        |> put_status(200)
        |> render("data_dump_index.json", data_dump)

      404 ->
        conn
        |> send_error(403, "Unauthorized")
    end
  end
end
