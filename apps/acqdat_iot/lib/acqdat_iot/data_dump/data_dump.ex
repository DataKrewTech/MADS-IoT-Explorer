defmodule AcqdatIot.DataDump do
  alias AcqdatCore.Model.IotManager.GatewayDataDump, as: GDDModel
  alias AcqdatIot.DataDump.Worker.Server

  def create(params) do
    params = params_extraction(params)
    {:ok, pid} = GenServer.start_link(Server, params)
    GenServer.cast(pid, {:data_dump, params})
  end

  defp params_extraction(params) do
    Map.from_struct(params)
    |> Map.drop([:_id, :__meta__])
  end
end
