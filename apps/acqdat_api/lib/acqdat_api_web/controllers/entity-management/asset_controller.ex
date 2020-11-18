defmodule AcqdatApiWeb.EntityManagement.AssetController do
  use AcqdatApiWeb, :controller
  alias AcqdatApi.EntityManagement.Asset
  alias AcqdatCore.Model.EntityManagement.AssetType, as: ATModel
  alias AcqdatApi.ElasticSearch
  import AcqdatApiWeb.Helpers
  import AcqdatApiWeb.Validators.EntityManagement.Asset

  plug AcqdatApiWeb.Plug.LoadProject
  plug :load_asset when action in [:show, :update, :delete]
  plug :check_org_and_asset_type when action in [:create]

  @spec show(Plug.Conn.t(), any) :: Plug.Conn.t()
  def show(conn, _params) do
    case conn.status do
      nil ->
        conn
        |> put_status(200)
        |> render("asset_tree.json", %{asset: Asset.asset_descendants(conn.assigns.asset)})

      404 ->
        conn
        |> send_error(404, "Resource Not Found")
    end
  end

  def create(conn, params) do
    case conn.status do
      nil ->
        changeset = verify_asset(params)

        with {:extract, {:ok, data}} <- {:extract, extract_changeset_data(changeset)},
             {:create, {:ok, asset}} <- {:create, Asset.create(data)} do
          Task.start_link(fn ->
            ElasticSearch.insert_asset("assets", asset)
          end)

          conn
          |> put_status(200)
          |> render("asset.json", %{asset: asset})
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

  def update(conn, params) do
    case conn.status do
      nil ->
        case Asset.update_asset(conn.assigns.asset, params) do
          {:ok, asset} ->
            ElasticSearch.update_asset("assets", asset)

            conn
            |> put_status(200)
            |> render("asset.json", %{asset: asset})

          {:error, asset} ->
            error = extract_changeset_error(asset)

            conn
            |> send_error(400, error)
        end

      404 ->
        conn
        |> send_error(404, "Resource Not Found")
    end
  end

  def index(conn, params) do
    case conn.status do
      nil ->
        with {:ok, hits} <- ElasticSearch.entities_indexing("assets", params) do
          conn |> put_status(200) |> render("hits.json", %{hits: hits})
        else
          {:error, message} ->
            conn
            |> put_status(404)
            |> json(%{
              "status_code" => 404,
              "title" => message,
              "detail" => message
            })
        end

      404 ->
        conn
        |> send_error(404, "Resource Not Found")
    end
  end

  def delete(conn, _params) do
    case conn.status do
      nil ->
        case Asset.delete(conn.assigns.asset) do
          {:ok, {_number, nil}} ->
            Task.start_link(fn ->
              ElasticSearch.delete("assets", conn.assigns.asset.id)
            end)

            conn
            |> put_status(200)
            |> render("asset.json", %{asset: conn.assigns.asset})
        end

      404 ->
        conn
        |> send_error(404, "Resource Not Found")
    end
  end

  def search_assets(conn, params) do
    case conn.status do
      nil ->
        with {:ok, hits} <- ElasticSearch.search_entities("assets", params) do
          conn |> put_status(200) |> render("hits.json", %{hits: hits})
        else
          {:error, message} ->
            conn
            |> put_status(404)
            |> json(%{
              "status_code" => 404,
              "title" => message,
              "detail" => message
            })
        end

      404 ->
        conn
        |> send_error(404, "Resource Not Found")
    end
  end

  defp load_asset(%{params: %{"id" => id}} = conn, _params) do
    {id, _} = Integer.parse(id)

    case Asset.get(id) do
      {:ok, asset} ->
        assign(conn, :asset, asset)

      {:error, _message} ->
        conn
        |> put_status(404)
    end
  end

  defp check_org_and_asset_type(
         %{params: %{"org_id" => org_id, "project_id" => project_id}} = conn,
         _params
       ) do
    check_org(conn, org_id, project_id)
  end

  defp check_org(conn, org_id, project_id) do
    {org_id, _} = Integer.parse(org_id)
    {project_id, _} = Integer.parse(project_id)

    case Asset.get(org_id, project_id) do
      {:ok, org} ->
        check_asset_type(conn, org.id)

      {:error, _message} ->
        conn
        |> put_status(404)
    end
  end

  defp check_asset_type(%{params: %{"asset_type_id" => asset_type_id}} = conn, _org_id) do
    case ATModel.get(asset_type_id) do
      {:ok, asset_type} ->
        assign(conn, :asset_type, asset_type)

      {:error, _message} ->
        conn
        |> put_status(404)
    end
  end
end
