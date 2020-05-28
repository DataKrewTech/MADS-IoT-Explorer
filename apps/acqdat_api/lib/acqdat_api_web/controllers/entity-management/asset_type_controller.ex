defmodule AcqdatApiWeb.EntityManagement.AssetTypeController do
  use AcqdatApiWeb, :controller
  alias AcqdatApi.EntityManagement.AssetType
  import AcqdatApiWeb.Helpers
  import AcqdatApiWeb.Validators.EntityManagement.AssetType

  @spec create(Plug.Conn.t(), any) :: Plug.Conn.t()
  def create(conn, params) do
    case conn.status do
      nil ->
        changeset = verify_asset_params(params)

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
end
