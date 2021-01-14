defmodule AcqdatApiWeb.DataInsights.PivotTablesChannel do
  use Phoenix.Channel

  intercept ["out_put_res_pivot"]

  def join("project_pivot_table:" <> pivot_table_id, _params, socket) do
    if socket.assigns.user_id do
      socket = assign(socket, :pivot_table_id, pivot_table_id)
      response = %{message: "Channel Joined Successfully PivotTable ID #{pivot_table_id}"}
      {:ok, response, socket}
    else
      {:error, %{reason: "unauthorized"}, socket}
    end
  end

  def handle_out("out_put_res_pivot", %{data: {:ok, payload}}, socket) do
    push(
      socket,
      "out_put_res_pivot",
      Phoenix.View.render(AcqdatApiWeb.DataInsights.PivotTablesView, "pivot_table_data.json", %{
        pivot_table: payload[:gen_pivot_data]
      })
    )

    {:noreply, socket}
  end
end
