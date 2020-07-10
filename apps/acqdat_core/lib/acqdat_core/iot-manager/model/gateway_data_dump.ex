defmodule AcqdatCore.Model.IotManager.GatewayDataDump do
  alias AcqdatCore.Repo
  alias AcqdatCore.Schema.IotManager.GatewayDataDump

  def create(params) do
    changeset = GatewayDataDump.changeset(%GatewayDataDump{}, params)
    Repo.insert(changeset)
  end
end
