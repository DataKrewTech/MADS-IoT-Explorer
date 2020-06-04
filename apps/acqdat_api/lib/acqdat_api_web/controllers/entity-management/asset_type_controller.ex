defmodule AcqdatApiWeb.EntityManagement.AssetTypeController do
  use AcqdatApiWeb, :controller
  import AcqdatApiWeb.Helpers
  import AcqdatApiWeb.Validators.EntityManagement.AssetType
  alias AcqdatApi.EntityManagement.AssetType

  plug :load_asset_type when action in [:update, :delete]

  def create(conn, params) do
    case conn.status do
      nil ->
        changeset = verify_asset_type_params(params)

        with {:extract, {:ok, data}} <- {:extract, extract_changeset_data(changeset)},
             {:create, {:ok, asset_type}} <- {:create, AssetType.create(data)} do
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
        |> send_error(404, "Resource Not Found")
    end
  end

  def index(conn, params) do
    changeset = verify_index_params(params)

    case conn.status do
      nil ->
        {:extract, {:ok, data}} = {:extract, extract_changeset_data(changeset)}
        {:list, asset_type} = {:list, AssetType.get_all(data, [:org, :project])}

        conn
        |> put_status(200)
        |> render("index.json", asset_type)

      404 ->
        conn
        |> send_error(404, "Resource Not Found")
    end
  end

  def update(conn, %{"asset_type" => params}) do
    case conn.status do
      nil ->
        case AssetType.update(conn.assigns.asset_type, params) do
          {:ok, asset_type} ->
            conn
            |> put_status(200)
            |> render("asset_type.json", %{asset_type: asset_type})

          {:error, asset_type} ->
            error =
              case String.valid?(asset_type) do
                false -> extract_changeset_error(asset_type)
                true -> asset_type
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
        case AssetType.delete(conn.assigns.asset_type) do
          {:ok, asset_type} ->
            conn
            |> put_status(200)
            |> render("asset_type.json", %{asset_type: asset_type})

          {:error, asset_type} ->
            error =
              case String.valid?(asset_type) do
                false -> extract_changeset_error(asset_type)
                true -> asset_type
              end

            conn
            |> send_error(400, error)
        end

      404 ->
        conn
        |> send_error(404, "Resource Not Found")
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
