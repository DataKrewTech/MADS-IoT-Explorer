defmodule AcqdatApiWeb.DataInsights.VisualizationsChannel do
  use Phoenix.Channel
  alias AcqdatApi.DataInsights.Visualizations

  intercept ["out_put_res_visualizations"]

  def join("visualizations:" <> visualization_id, _params, socket) do
    if socket.assigns.user_id do
      socket = assign(socket, :visualization_id, visualization_id)
      response = %{message: "Channel Joined Successfully Visualization Id #{visualization_id}"}
      {:ok, response, socket}
    else
      {:error, %{reason: "unauthorized"}, socket}
    end
  end

  def handle_out(
        "out_put_res_visualizations",
        %{data: {:ok, %{gen_pivot_data: gen_pivot_data}}},
        socket
      ) do
    socket |> push_on_channel(gen_pivot_data)
  end

  def handle_out("out_put_res_visualizations", %{data: {:ok, data}}, socket) do
    socket |> push_on_channel(data)
  end

  def handle_out("out_put_res_visualizations", %{data: {:error, err_msg}}, socket) do
    socket |> push_on_channel(%{error: err_msg})
  end

  def handle_in(
        "visualizations_data",
        %{
          "visualization_id" => visualization_id
        },
        socket
      ) do
    data = Visualizations.gen_data(visualization_id)

    broadcast!(socket, "out_put_res_visualizations", %{data: data})
    {:reply, :ok, socket}
  end

  defp push_on_channel(socket, data) do
    push(
      socket,
      "out_put_res_visualizations",
      Phoenix.View.render(AcqdatApiWeb.DataInsights.PivotTablesView, "pivot_table_data.json", %{
        pivot_table: data
      })
    )

    {:noreply, socket}
  end
end
