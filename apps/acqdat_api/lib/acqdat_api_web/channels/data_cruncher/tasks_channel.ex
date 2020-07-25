defmodule AcqdatApiWeb.DataCruncher.TasksChannel do
  use Phoenix.Channel

  def join("room:lobby", _message, socket) do
    {:ok, socket}
  end

  # def join("room:" <> _private_room_id, _params, _socket) do
  #   {:error, %{reason: "unauthorized"}}
  # end
  def join("tasks:" <> task_id, _params, socket) do
    # task = fetch_task(task_id)
    # send(self, {:after_join, task})
    require IEx
    IEx.pry()
    socket = assign(socket, :task, "task")
    response = %{task: "task"}
    {:ok, response, socket}
  end

  # def handle_info({:after_join, task}, socket) do
  #   # store user in our Presence store
  #   # broadcast out the new list of users to subscribers
  #   # send the list of existing users to the newly joined client

  #   # broadcast! socket, "response:updated", %{challenge: challenge}
  # end

  # def handle_in("task_output", res, socket) do
  #   push(socket, "task_output", res)
  #   {:noreply, socket}
  # end

  def handle_in("out_put_res", msg, socket) do
    push(socket, "out_put_res", msg)
    IO.puts("i am a recommendation !")
    IO.inspect(msg)
    #  chat_msg = %{
    #     "creator_id" => msg["user_grapqhl_id"],
    #     "text" => msg["message"],
    #     "creator_name" => msg["user_name"]
    #  }

    # broadcast! socket, "new:msg", create_chat_msg(chat_msg,socket)
    {:reply, :ok, socket}
  end
end
