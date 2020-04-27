defmodule AcqdatApiWeb.TeamController do
  use AcqdatApiWeb, :controller
  alias AcqdatApi.Team
  alias AcqdatCore.Model.Team, as: TeamModel
  import AcqdatApiWeb.Validators.Team
  import AcqdatApiWeb.Helpers

  plug(AcqdatApiWeb.Plug.LoadUser)
  plug :load_team when action in [:update, :assets, :apps, :members]

  def create(conn, %{"team" => params}) do
    case conn.status do
      nil ->
        changeset = verify_create_params(params)

        with {:extract, {:ok, data}} <- {:extract, extract_changeset_data(changeset)},
             {:create, {:ok, team}} <- {:create, Team.create(data, conn.assigns.current_user)} do
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

  def assets(conn, %{"team" => params}) do
    case conn.status do
      nil ->
        %{assigns: %{team: team}} = conn
        changeset = verify_assets_params(params)

        with {:extract, {:ok, data}} <- {:extract, extract_changeset_data(changeset)},
             {:create, {:ok, team_res}} <- {:create, Team.update_assets(team, data)} do
          conn
          |> put_status(200)
          |> render("team_assets.json", %{team: team_res})
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

  def apps(conn, %{"team" => params}) do
    case conn.status do
      nil ->
        %{assigns: %{team: team}} = conn
        changeset = verify_apps_params(params)

        with {:extract, {:ok, data}} <- {:extract, extract_changeset_data(changeset)},
             {:create, {:ok, team_res}} <- {:create, Team.update_apps(team, data)} do
          conn
          |> put_status(200)
          |> render("team_apps.json", %{team: team_res})
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

  def members(conn, %{"team" => params}) do
    case conn.status do
      nil ->
        %{assigns: %{team: team}} = conn
        changeset = verify_members_params(params)

        with {:extract, {:ok, data}} <- {:extract, extract_changeset_data(changeset)},
             {:create, {:ok, team_res}} <- {:create, Team.update_members(team, data)} do
          conn
          |> put_status(200)
          |> render("team_members.json", %{team: team_res})
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

  def update(conn, %{"team" => params}) do
    case conn.status do
      nil ->
        %{assigns: %{team: team}} = conn
        changeset = verify_update_params(params)

        with {:extract, {:ok, data}} <- {:extract, extract_changeset_data(changeset)},
             {:create, {:ok, team_res}} <- {:create, Team.update(team, data)} do
          conn
          |> put_status(200)
          |> render("team_details.json", %{team: team_res})
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

  def index(conn, params) do
    changeset = verify_index_params(params)

    case conn.status do
      nil ->
        {:extract, {:ok, data}} = {:extract, extract_changeset_data(changeset)}
        {:list, sensor} = {:list, TeamModel.get_all(data)}

        conn
        |> put_status(200)
        |> render("index.json", sensor)

      404 ->
        conn
        |> send_error(404, "Resource Not Found")
    end
  end

  defp load_team(%{params: %{"id" => id}} = conn, _params) do
    {id, _} = Integer.parse(id)

    case Team.get(id) do
      {:ok, team} ->
        assign(conn, :team, team)

      {:error, _message} ->
        conn
        |> put_status(404)
    end
  end
end
