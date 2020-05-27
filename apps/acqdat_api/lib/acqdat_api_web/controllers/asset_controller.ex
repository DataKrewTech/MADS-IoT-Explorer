defmodule AcqdatApiWeb.AssetController do
  use AcqdatApiWeb, :controller
  alias AcqdatCore.Model.Asset, as: AssetModel
  alias AcqdatCore.Model.Organisation, as: OrgModel
  alias AcqdatApi.ElasticSearch
  alias AcqdatApi.Asset
  import AcqdatApiWeb.Helpers
  import AcqdatApiWeb.Validators.Asset

  plug :load_asset when action in [:show, :update, :delete]
  plug :load_org when action in [:search_assets, :create]

  @spec show(Plug.Conn.t(), any) :: Plug.Conn.t()
  def show(conn, _params) do
    case conn.status do
      nil ->
        conn
        |> put_status(200)
        |> render("asset.json", %{asset: conn.assigns.asset})

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
        case AssetModel.update(conn.assigns.asset, params) do
          {:ok, asset} ->
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
    changeset = verify_index_params(params)

    case conn.status do
      nil ->
        {:extract, {:ok, data}} = {:extract, extract_changeset_data(changeset)}
        {:list, asset} = {:list, AssetModel.get_all(data, [])}

        conn
        |> put_status(200)
        |> render("index.json", asset)

      404 ->
        conn
        |> send_error(404, "Resource Not Found")
    end
  end

  def delete(conn, _params) do
    case conn.status do
      nil ->
        case AssetModel.delete(conn.assigns.asset) do
          {_number, nil} ->
            conn
            |> put_status(200)
            |> render("asset.json", %{asset: conn.assigns.asset})
        end

      404 ->
        conn
        |> send_error(404, "Resource Not Found")
    end
  end

  def search_assets(conn, %{"label" => label}) do
    case conn.status do
      nil ->
        with {:ok, hits} <- ElasticSearch.search_assets("assets", label) do
          conn |> put_status(200) |> render("hits.json", %{hits: hits})
        else
          {:error, message} ->
            conn
            |> put_status(404)
            |> json(%{
              "success" => false,
              "error" => true,
              "message:" => message
            })
        end

      404 ->
        conn
        |> send_error(404, "Resource Not Found")
    end
  end

  defp load_asset(%{params: %{"id" => id}} = conn, _params) do
    {id, _} = Integer.parse(id)

    case AssetModel.get(id) do
      {:ok, asset} ->
        assign(conn, :asset, asset)

      {:error, _message} ->
        conn
        |> put_status(404)
    end
  end

  defp load_org(%{params: %{"org_id" => org_id}} = conn, _params) do
    check_org(conn, org_id)
  end

  defp check_org(conn, org_id) do
    {org_id, _} = Integer.parse(org_id)

    case OrgModel.get(org_id) do
      {:ok, org} ->
        assign(conn, :org, org)

      {:error, _message} ->
        conn
        |> put_status(404)
    end
  end
end
