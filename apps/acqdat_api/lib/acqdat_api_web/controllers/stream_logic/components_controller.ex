defmodule AcqdatApiWeb.StreamLogic.ComponentsController do
  use AcqdatApiWeb, :controller
  alias AcqdatApi.StreamLogic.Component

  def components(conn, _) do
    components = Component.components()
    conn
    |> put_status(200)
    |> render("components.json", %{components: components})
  end
end
