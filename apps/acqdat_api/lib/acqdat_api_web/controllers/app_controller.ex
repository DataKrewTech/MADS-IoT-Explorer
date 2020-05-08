defmodule AcqdatApiWeb.AppController do
  use AcqdatApiWeb, :controller
  import AcqdatApiWeb.Helpers
  import AcqdatApiWeb.Validators.App
  alias AcqdatCore.Model.App, as: AppModel

  defdelegate get_all(data), to: AppModel
  defdelegate fetch_all_apps(data), to: AppModel, as: :get_all

  def index(conn, params) do
    changeset = verify_index_params(params)

    case conn.status do
      nil ->
        with {:extract, {:ok, data}} <- {:extract, extract_changeset_data(changeset)},
             {:list, apps} <- {:list, fetch_all_apps(data)} do
          conn
          |> put_status(200)
          |> render("index.json", apps)
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
