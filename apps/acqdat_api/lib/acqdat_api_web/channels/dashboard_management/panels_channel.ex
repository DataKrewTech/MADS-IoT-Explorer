defmodule AcqdatApiWeb.DashboardManagement.PanelsChannel do
  use Phoenix.Channel

  intercept ["out_put_res"]

  def join("panels:" <> panel_id, _, socket) do
    if socket.assigns.user_id do
      socket = assign(socket, :panel, panel_id)
      response = %{message: "Channel Joined Successfully #{panel_id}"}
      {:ok, response, socket}
    else
      {:error, %{reason: "unauthorized"}, socket}
    end
  end

  def handle_out("out_put_res", %{data: {:error, err_msg}}, socket) do
    socket |> push_on_channel(%{error: err_msg}, "error_data")
  end

  def handle_out("out_put_res", %{data: {:ok, data}}, socket) do
    socket |> push_on_channel(data, "create")
  end

  defp push_on_channel(socket, widget_inst, action_type) do
    push(
      socket,
      "out_put_res",
      Phoenix.View.render(
        AcqdatApiWeb.DashboardManagement.WidgetInstanceView,
        "#{action_type}.json",
        %{widget_instance: widget_inst}
      )
    )

    {:noreply, socket}
  end
end
