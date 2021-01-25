defmodule AcqdatApiWeb.DataInsights.PivotTablesChannel do
  use Phoenix.Channel
  alias AcqdatApi.DataInsights.PivotTables

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

  def handle_out("out_put_res_pivot", %{data: {:ok, %{gen_pivot_data: gen_pivot_data}}}, socket) do
    socket |> push_on_channel(gen_pivot_data)
  end

  def handle_out("out_put_res_pivot", %{data: {:ok, data}}, socket) do
    socket |> push_on_channel(data)
  end

  def handle_out("out_put_res_pivot", %{data: {:error, err_msg}}, socket) do
    socket |> push_on_channel(%{error: err_msg})
  end

  def handle_in(
        "pivot_table_data",
        %{
          "pivot_table_id" => pivot_table_id
        },
        socket
      ) do
    data = PivotTables.fetch_n_gen_pivot(pivot_table_id)

    broadcast!(socket, "out_put_res_pivot", %{data: data})
    {:reply, :ok, socket}
  end

  defp push_on_channel(socket, data) do
    push(
      socket,
      "out_put_res_pivot",
      Phoenix.View.render(AcqdatApiWeb.DataInsights.PivotTablesView, "pivot_table_data.json", %{
        pivot_table: data
      })
    )

    {:noreply, socket}
  end
end
