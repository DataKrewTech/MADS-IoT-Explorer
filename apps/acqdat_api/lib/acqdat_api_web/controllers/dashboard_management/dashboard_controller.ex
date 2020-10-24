defmodule AcqdatApiWeb.DashboardManagement.DashboardController do
  use AcqdatApiWeb, :controller
  import AcqdatApiWeb.Helpers
  import AcqdatApiWeb.Validators.DashboardManagement.Dashboard
  alias AcqdatApi.DashboardManagement.Dashboard
  alias AcqdatApi.Image
  alias AcqdatApi.ImageDeletion

  plug AcqdatApiWeb.Plug.LoadOrg when not (action in [:exported_dashboard])
  plug AcqdatApiWeb.Plug.LoadDashboard when action in [:update, :delete]

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
        |> send_error(404, "Resource Not Found")
    end
  end

  def create(conn, params) do
    case conn.status do
      nil ->
        params = add_avatar_to_params(conn, params)
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
            send_error(conn, 400, message)
        end

      404 ->
        conn
        |> send_error(404, "Resource Not Found")
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
            conn
            |> put_status(200)
            |> render("show.json", %{dashboard: dashboard})
        end

      404 ->
        conn
        |> send_error(404, "Resource Not Found")
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
        |> send_error(404, "Resource Not Found")
    end
  end

  def delete(conn, _params) do
    case conn.status do
      nil ->
        case Dashboard.delete(conn.assigns.dashboard) do
          {:ok, dashboard} ->
            if dashboard.avatar != nil do
              ImageDeletion.delete_operation(dashboard.avatar, "dashboard")
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
        |> send_error(404, "Resource Not Found")
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

      401 ->
        conn
        |> send_error(401, "Unauthorized link")
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

  defp add_avatar_to_params(conn, params) do
    params = Map.put(params, "avatar", "")

    case is_nil(params["image"]) do
      true ->
        params

      false ->
        add_image_url(conn, params)
    end
  end

  defp extract_image(conn, dashboard, params) do
    case is_nil(params["image"]) do
      true ->
        params

      false ->
        if dashboard.avatar != nil do
          ImageDeletion.delete_operation(dashboard.avatar, "dashboard")
        end

        add_image_url(conn, params)
    end
  end

  defp add_image_url(conn, %{"image" => image} = params) do
    with {:ok, image_name} <- Image.store({image, "dashboard"}) do
      Map.replace!(params, "avatar", Image.url({image_name, "dashboard"}))
    else
      {:error, error} -> send_error(conn, 400, error)
    end
  end
end
