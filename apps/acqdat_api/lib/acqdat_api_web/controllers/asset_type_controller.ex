defmodule AcqdatApiWeb.AssetTypeController do
  use AcqdatApiWeb, :controller
  alias AcqdatApi.AssetType
  import AcqdatApiWeb.Helpers

  plug :load_asset_type when action in [:update]

  def update(conn, %{"asset_type" => params}) do
    case conn.status do
      nil ->
        case AssetType.update_asset(conn.assigns.asset_type, params) do
          {:ok, asset_type} ->
            conn
            |> put_status(200)
            |> render("asset_type.json", %{asset_type: asset_type})

          {:error, asset_type} ->
            error = extract_changeset_error(asset_type)

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
