defmodule AcqdatApiWeb.EntityManagement.AssetTypeController do
  use AcqdatApiWeb, :authorized_controller
  import AcqdatApiWeb.Helpers
  import AcqdatApiWeb.Validators.EntityManagement.AssetType
  alias AcqdatApi.EntityManagement.AssetType
  alias AcqdatApiWeb.EntityManagement.AssetTypeErrorHelper
  alias AcqdatCore.ElasticSearch

  plug AcqdatApiWeb.Plug.LoadProject
  plug AcqdatApiWeb.Plug.LoadOrg
  plug :load_asset_type when action in [:update, :delete]

  def create(conn, params) do
    case conn.status do
      nil ->
        changeset = verify_asset_type_params(params)

        with {:extract, {:ok, data}} <-
               {:extract, extract_changeset_data(changeset)},
             {:create, {:ok, asset_type}} <- {:create, AssetType.create(data)} do
          Task.start_link(fn ->
            ElasticSearch.insert_asset_type("asset_types", asset_type)
          end)

          conn
          |> put_status(200)
          |> render("asset_type.json", %{asset_type: asset_type})
        else
          {:extract, {:error, error}} ->
            send_error(conn, 400, error)

          {:create, {:error, message}} ->
            send_error(conn, 400, message)
        end

      404 ->
        conn
        |> send_error(404, AssetTypeErrorHelper.error_message(:resource_not_found))

      401 ->
        conn
        |> send_error(401, AssetTypeErrorHelper.error_message(:unauthorized))
    end
  end

  def search_asset_type(conn, params) do
    case conn.status do
      nil ->
        with {:ok, hits} <- ElasticSearch.search_entities("asset_types", params) do
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
        |> send_error(404, AssetTypeErrorHelper.error_message(:resource_not_found))

      401 ->
        conn
        |> send_error(401, AssetTypeErrorHelper.error_message(:unauthorized))
    end
  end

  def index(conn, params) do
    case conn.status do
      nil ->
        with {:ok, hits} <- ElasticSearch.entities_indexing("asset_types", params) do
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
        |> send_error(404, AssetTypeErrorHelper.error_message(:resource_not_found))

      401 ->
        conn
        |> send_error(401, AssetTypeErrorHelper.error_message(:unauthorized))
    end
  end

  def update(conn, params) do
    case conn.status do
      nil ->
        case AssetType.update(conn.assigns.asset_type, params) do
          {:ok, asset_type} ->
            Task.start_link(fn ->
              ElasticSearch.insert_asset_type("asset_types", asset_type)
            end)

            conn
            |> put_status(200)
            |> render("asset_type.json", %{asset_type: asset_type})

          {:error, %Ecto.Changeset{} = changeset} ->
            error = extract_changeset_error(changeset)

            conn
            |> send_error(400, error)

          {:error, error} ->
            conn
            |> send_error(400, AssetTypeErrorHelper.error_message(:asset_association, error))
        end

      404 ->
        conn
        |> send_error(404, AssetTypeErrorHelper.error_message(:resource_not_found))

      401 ->
        conn
        |> send_error(401, AssetTypeErrorHelper.error_message(:unauthorized))
    end
  end

  def delete(conn, _params) do
    case conn.status do
      nil ->
        case AssetType.delete(conn.assigns.asset_type) do
          {:ok, asset_type} ->
            Task.start_link(fn ->
              ElasticSearch.delete("asset_types", conn.assigns.asset_type.id)
            end)

            conn
            |> put_status(200)
            |> render("asset_type.json", %{asset_type: asset_type})

          {:error, %Ecto.Changeset{} = changeset} ->
            error = extract_changeset_error(changeset)

            conn
            |> send_error(400, error)

          {:error, error} ->
            conn
            |> send_error(400, AssetTypeErrorHelper.error_message(:asset_association, error))
        end

      404 ->
        conn
        |> send_error(404, AssetTypeErrorHelper.error_message(:resource_not_found))

      401 ->
        conn
        |> send_error(401, AssetTypeErrorHelper.error_message(:unauthorized))
    end
  end

  defp load_asset_type(%{params: %{"id" => id}} = conn, _params) do
    {id, _} = Integer.parse(id)

    case AssetType.get(id) do
      {:ok, asset_type} ->
        assign(conn, :asset_type, asset_type)

      {:error, _message} ->
        conn
        |> put_status(404)
    end
  end
end
