defmodule AcqdatApiWeb.TeamController do
  use AcqdatApiWeb, :controller
  alias AcqdatApi.Team
  import AcqdatApiWeb.Validators.Team
  import AcqdatApiWeb.Helpers

  def create(conn, %{"team" => params}) do
    case conn.status do
      nil ->
        changeset = verify_create_params(params)

        with {:extract, {:ok, data}} <- {:extract, extract_changeset_data(changeset)},
             {:create, {:ok, team}} <- {:create, Team.create(data)} do
          conn
          |> put_status(200)
          |> render("team_details.json", %{team: team})
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
end
