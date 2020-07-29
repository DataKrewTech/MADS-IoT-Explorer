defmodule AcqdatApiWeb.DataCruncher.TasksChannel do
  use Phoenix.Channel

  intercept ["out_put_res"]

  def join("tasks:" <> task_id, _params, socket) do
    if socket.assigns.user_id do
      socket = assign(socket, :task, task_id)
      response = %{message: "Channel Joined Successfully #{task_id}"}
      {:ok, response, socket}
    else
      {:error, %{reason: "unauthorized"}, socket}
    end
  end

  def handle_out("out_put_res", %{data: payload}, socket) do
    push(socket, "out_put_res", %{
      task:
        Phoenix.View.render(AcqdatApiWeb.DataCruncher.TasksView, "task.json", %{task: payload})
    })

    {:noreply, socket}
  end
end
