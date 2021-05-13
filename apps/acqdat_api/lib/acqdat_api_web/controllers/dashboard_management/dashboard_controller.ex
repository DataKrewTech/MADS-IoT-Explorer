defmodule AcqdatApiWeb.DashboardManagement.DashboardController do
  use AcqdatApiWeb, :authorized_controller
  import AcqdatApiWeb.Helpers
  import AcqdatApiWeb.Validators.DashboardManagement.Dashboard
  alias AcqdatApi.DashboardManagement.Dashboard
  alias AcqdatApiWeb.DashboardManagement.DashboardErrorHelper
  alias AcqdatApi.Helper.Redis
  alias AcqdatApi.Image
  alias AcqdatApi.ImageDeletion

  plug AcqdatApiWeb.Plug.LoadOrg when not (action in [:exported_dashboard])
  plug AcqdatApiWeb.Plug.LoadDashboard when action in [:show, :update, :delete]

  def index(conn, params) do
    changeset = verify_index_params(params)

    case conn.status do
      nil ->
        {:extract, {:ok, data}} = {:extract, extract_changeset_data(changeset)}
        {:list, dashboards} = {:list, Dashboard.get_all(data)}

        conn
        |> put_status(200)
        |> render("index.json", dashboards)

      404 ->
        conn
        |> send_error(404, DashboardErrorHelper.error_message(:resource_not_found))

      401 ->
        conn
        |> send_error(401, DashboardErrorHelper.error_message(:unauthorized))
    end
  end

  def create(conn, params) do
    case conn.status do
      nil ->
        params =
          params
          |> Map.put_new("creator_id", String.to_integer(Guardian.Plug.current_resource(conn)))

        changeset = verify_create(params)

        with {:extract, {:ok, data}} <- {:extract, extract_changeset_data(changeset)},
             {:create, {:ok, dashboard}} <- {:create, Dashboard.create(data)} do
          conn
          |> put_status(200)
          |> render("show.json", %{dashboard: dashboard})
        else
          {:extract, {:error, error}} ->
            send_error(conn, 400, error)

          {:create, {:error, message}} ->
            response =
              case is_map(message.error) do
                false -> message
                true -> message.error
              end

            send_error(conn, 400, response)
        end

      404 ->
        conn
        |> send_error(404, DashboardErrorHelper.error_message(:resource_not_found))

      401 ->
        conn
        |> send_error(401, DashboardErrorHelper.error_message(:unauthorized))
    end
  end

  def show(conn, %{"id" => id}) do
    case conn.status do
      nil ->
        {id, _} = Integer.parse(id)

        case Dashboard.get_with_panels(id) do
          {:error, message} ->
            send_error(conn, 400, message)

          {:ok, dashboard} ->
            case Redis.insert_dashboard(
                   dashboard,
                   String.to_integer(Guardian.Plug.current_resource(conn))
                 ) do
              {:ok, _} ->
                Dashboard.update(dashboard, %{opened_on: DateTime.utc_now()})

                conn
                |> put_status(200)
                |> render("show.json", %{dashboard: dashboard})

              {:error, message} ->
                conn
                |> send_error(400, DashboardErrorHelper.error_message(:redis_error, message))
            end
        end

      404 ->
        conn
        |> send_error(404, DashboardErrorHelper.error_message(:resource_not_found))

      401 ->
        conn
        |> send_error(401, DashboardErrorHelper.error_message(:unauthorized))
    end
  end

  def update(conn, params) do
    case conn.status do
      nil ->
        dashboard = conn.assigns.dashboard
        params = Map.put(params, "avatar", dashboard.avatar)
        params = extract_image(conn, dashboard, params)

        case Dashboard.update(dashboard, params) do
          {:ok, dashboard} ->
            conn
            |> put_status(200)
            |> render("dashboard.json", %{dashboard: dashboard})

          {:error, dashboard} ->
            error =
              case String.valid?(dashboard) do
                false -> extract_changeset_error(dashboard)
                true -> dashboard
              end

            conn
            |> send_error(400, error)
        end

      404 ->
        conn
        |> send_error(404, DashboardErrorHelper.error_message(:resource_not_found))

      401 ->
        conn
        |> send_error(401, DashboardErrorHelper.error_message(:unauthorized))
    end
  end

  def delete(conn, _params) do
    case conn.status do
      nil ->
        case Dashboard.delete(conn.assigns.dashboard) do
          {:ok, dashboard} ->
            if dashboard.avatar != nil do
              ImageDeletion.delete_operation(dashboard.avatar, "dashboard_image/#{dashboard.id}")
            end

            if dashboard.settings.client_logo != nil do
              ImageDeletion.delete_operation(
                dashboard.settings.client_logo,
                "dashboard_settings/#{dashboard.id}"
              )
            end

            conn
            |> put_status(200)
            |> render("dashboard.json", %{dashboard: dashboard})

          {:error, dashboard} ->
            error =
              case String.valid?(dashboard) do
                false -> extract_changeset_error(dashboard)
                true -> dashboard
              end

            conn
            |> send_error(400, error)
        end

      404 ->
        conn
        |> send_error(404, DashboardErrorHelper.error_message(:resource_not_found))

      401 ->
        conn
        |> send_error(401, DashboardErrorHelper.error_message(:unauthorized))
    end
  end

  def recent_dashboard(conn, params) do
    changeset = verify_index_params(params)

    case conn.status do
      nil ->
        {:extract, {:ok, data}} = {:extract, extract_changeset_data(changeset)}

        case Redis.get_dashboard_ids(String.to_integer(Guardian.Plug.current_resource(conn))) do
          {:ok, dashboard_ids} ->
            data = Map.put_new(data, :dashboard_ids, dashboard_ids)
            {:list, dashboards} = {:list, Dashboard.recent_dashboards(data)}

            conn
            |> put_status(200)
            |> render("index.json", dashboards)

          {:error, message} ->
            conn
            |> send_error(400, DashboardErrorHelper.error_message(:redis_error, message))
        end

      404 ->
        conn
        |> send_error(404, DashboardErrorHelper.error_message(:resource_not_found))

      401 ->
        conn
        |> send_error(401, DashboardErrorHelper.error_message(:unauthorized))
    end
  end

  def exported_dashboard(conn, params) do
    case conn.status do
      nil ->
        exported_dashboard = conn.assigns.exported_dashboard

        dashboard =
          check_exported_dashboard(exported_dashboard.is_secure, params, exported_dashboard)

        case dashboard do
          {:ok, dashboard} ->
            conn
            |> put_status(200)
            |> render("show.json", %{dashboard: dashboard})

          {:error, message} ->
            send_error(conn, 400, message)

          nil ->
            conn
            |> send_error(401, "Unauthorized link")
        end

      404 ->
        conn
        |> send_error(404, DashboardErrorHelper.error_message(:resource_not_found))

      401 ->
        conn
        |> send_error(401, DashboardErrorHelper.error_message(:unauthorized))
    end
  end

  ############################# private functions ###########################
  defp check_exported_dashboard(true, params, exported_dashboard) do
    case check_password(params["password"], exported_dashboard.password) do
      false ->
        nil

      true ->
        Dashboard.get_by_uuid(exported_dashboard.dashboard_uuid)
    end
  end

  defp check_exported_dashboard(false, params, exported_dashboard) do
    Dashboard.get_by_uuid(exported_dashboard.dashboard_uuid)
  end

  defp check_password(password, db_password) do
    if password == db_password do
      true
    else
      false
    end
  end

  defp extract_image(conn, dashboard, params) do
    with {:update_dashboad_logo, {:ok, data}} <-
           {:update_dashboad_logo, update_and_delete_image(conn, dashboard, params, "image")},
         {:update_client_logo, {:ok, updated_params}} <-
           {:update_client_logo, update_and_delete_image(conn, dashboard, data, "settings")} do
      updated_params
    else
      {:update_dashboad_logo, {:error, error}} ->
        send_error(conn, 400, error)

      {:update_client_logo, {:error, error}} ->
        send_error(conn, 400, error)
    end
  end

  defp update_and_delete_image(conn, dashboard, params, type) do
    {image_params, persisted_image} =
      if type == "settings" do
        {params["settings"]["client_logo"], dashboard.settings.client_logo}
      else
        {params["image"], dashboard.avatar}
      end

    case is_nil(image_params) do
      true ->
        {:ok, params}

      false ->
        if persisted_image != nil do
          ImageDeletion.delete_operation(persisted_image, "dashboard_#{type}/#{dashboard.id}")
        end

        add_image_url(conn, params, dashboard.id, type)
    end
  end

  defp add_image_url(conn, params, entity_id, type) do
    scope = "dashboard_#{type}/#{entity_id}"

    image = if type == "settings", do: params["settings"]["client_logo"], else: params["image"]

    with {:ok, image_name} <- Image.store({image, scope}) do
      params =
        if type == "settings" do
          update_in(params, ["settings", "client_logo"], fn _ ->
            Image.url({image_name, scope})
          end)
        else
          Map.replace!(params, "avatar", Image.url({image_name, scope}))
        end

      {:ok, params}
    else
      {:error, error} -> {:error, error}
    end
  end
end
