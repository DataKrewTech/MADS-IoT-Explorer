defmodule AcqdatApiWeb.DashboardManagement.DashboardController do
  use AcqdatApiWeb, :controller
  import AcqdatApiWeb.Helpers
  import AcqdatApiWeb.Validators.DashboardManagement.Dashboard
  alias AcqdatApi.DashboardManagement.Dashboard

  # alias AcqdatApi.Image
  # alias AcqdatApi.ImageDeletion

  plug AcqdatApiWeb.Plug.LoadOrg
  plug AcqdatApiWeb.Plug.LoadProject

  @doc """
  This piece of code will be useful when we will implement Project role based listing

  ## Examples

    case ProjectModel.check_adminship(Guardian.Plug.current_resource(conn)) do
    true ->
     false ->
       conn
       |> send_error(404, "User is not admin!")
    end
  """

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
end
