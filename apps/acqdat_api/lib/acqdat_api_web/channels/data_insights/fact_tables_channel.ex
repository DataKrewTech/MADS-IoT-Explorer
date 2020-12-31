defmodule AcqdatApiWeb.DataInsights.TasksChannel do
  use Phoenix.Channel
  alias AcqdatApi.DataInsights.Topology

  intercept ["out_put_res"]

  def join("project_fact_table:" <> fact_table_id, _params, socket) do
    if socket.assigns.user_id do
      socket = assign(socket, :fact_table_id, fact_table_id)
      response = %{message: "Channel Joined Successfully FactTable ID #{fact_table_id}"}
      {:ok, response, socket}
    else
      {:error, %{reason: "unauthorized"}, socket}
    end
  end

  def handle_out("out_put_res", %{data: payload}, socket) do
    push(
      socket,
      "out_put_res",
      Phoenix.View.render(AcqdatApiWeb.DataInsights.FactTablesView, "fact_table_data.json", %{
        fact_table: payload
      })
    )

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
