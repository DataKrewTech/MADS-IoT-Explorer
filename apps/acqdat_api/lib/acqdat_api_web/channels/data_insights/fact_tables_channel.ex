defmodule AcqdatApiWeb.DataInsights.TasksChannel do
  use Phoenix.Channel
  alias AcqdatApiWeb.DataInsights.Topology

  intercept ["out_put_res"]

  def join("project_fact_table:" <> project_id, _params, socket) do
    # if socket.assigns.user_id do
    #   socket = assign(socket, :project, project_id)
    #   response = %{message: "Channel Joined Successfully #{project_id}"}
    #   {:ok, response, socket}
    # else
    #   {:error, %{reason: "unauthorized"}, socket}
    # end
    response = %{message: "Channel Joined Successfully #{project_id}"}
    {:ok, response, socket}
  end

  def handle_out("out_put_res", %{data: payload}, socket) do
    push(socket, "out_put_res", %{
      task: payload
      # Phoenix.View.render(AcqdatApiWeb.DataCruncher.TasksView, "task.json", %{task: payload})
    })

    {:noreply, socket}
  end

  def handle_in(
        "ft_paginated_data",
        %{
          "page_number" => page_number,
          "page_size" => page_size,
          "fact_table_id" => fact_table_id
        },
        socket
      ) do
    IO.inspect(page_number)
    IO.inspect(page_size)

    data =
      Topology.fetch_paginated_fact_table("fact_table_#{fact_table_id}", page_number, page_size)

    broadcast!(socket, "out_put_res", %{data: data})
    {:reply, :ok, socket}
  end
end
