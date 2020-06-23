defmodule AcqdatCore.Model.EntityManagement.GatewayDataDump do
  alias AcqdatCore.Repo
  alias AcqdatCore.Schema.EntityManagement.GatewayDataDump

  def create(params) do
    changeset = GatewayDataDump.changeset(%GatewayDataDump{}, params)
    Repo.insert(changeset)
  end
end
