defmodule AcqdatIot.DataDump.Worker do
  use GenServer
  alias AcqdatIot.DataDump
  alias AcqdatIot.DataParser.Worker.Server
  alias AcqdatCore.Model.EntityManagement.GatewayDataDump, as: GDDModel
  import AcqdatApiWeb.Helpers

  def start_link(_) do
    GenServer.start_link(__MODULE__, nil)
  end

  def init(_args) do
    {:ok, nil}
  end

  def handle_cast({:data_dump, params}, _state) do
    response = verify_data_dump(GDDModel.create(params))
    {:noreply, response}
  end

  defp verify_data_dump({:ok, data}) do
    {:ok, pid} = GenServer.start_link(Server, data)
    GenServer.cast(pid, {:data_parser, data})
    {:ok, data}
  end

  defp verify_data_dump({:error, data}) do
    {:error, %{error: extract_changeset_error(data)}}
  end
end
