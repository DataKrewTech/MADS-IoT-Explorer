defmodule AcqdatApiWeb.AssetController do
  use AcqdatApiWeb, :controller
  alias AcqdatCore.Model.Asset, as: AssetModel
  import AcqdatApiWeb.Helpers

  defdelegate asset_descendents(id), to: AssetModel
  defdelegate get(id), to: AssetModel

  plug :load_asset when action in [:show, :update, :delete]

  @spec show(Plug.Conn.t(), any) :: Plug.Conn.t()
  def show(conn, _params) do
    case conn.status do
      nil ->
        conn
        |> put_status(200)
        |> render("asset_tree.json", %{asset: asset_descendents(conn.assigns.asset)})

      404 ->
        conn
        |> send_error(404, "Resource Not Found")
    end
  end

  defp load_asset(%{params: %{"id" => id}} = conn, _params) do
    {id, _} = Integer.parse(id)

    case get(id) do
      {:ok, asset} ->
        assign(conn, :asset, asset)

      {:error, _message} ->
        conn
        |> put_status(404)
    end
  end
end
