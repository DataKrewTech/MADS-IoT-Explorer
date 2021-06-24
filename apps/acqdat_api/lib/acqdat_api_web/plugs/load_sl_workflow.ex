defmodule AcqdatApiWeb.Plug.LoadStreamLogicWorkflow do
  import Plug.Conn
  alias AcqdatCore.StreamLogic.Model

  def init(default), do: default

  def call(%{params: %{"id" => id}} = conn, _params) do
    case Integer.parse(id) do
      {id, _} ->
        case Model.get(id) do
          {:ok, workflow} ->
            assign(conn, :workflow, workflow)

          {:error, _message} ->
            conn
            |> assign(:error_message, "workflow not found")
            |> put_status(404)
        end

      :error ->
        conn
        |> assign(:error_message, "workflow not found")
        |> put_status(404)
    end
  end
end
