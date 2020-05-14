defmodule AcqdatCore.Model.EntityManagement.GatewayData do
  @moduledoc """
  The Module exposes helper functions to interact with gateway_data
  data.
  """
  alias AcqdatCore.Schema.EntityManagement.GatewayData
  alias AcqdatCore.Repo

  # TODO:: Need to add differenet actions for all the read queries from timescale, as per the future requirements

  def create(params) do
    changeset = GatewayData.changeset(%GatewayData{}, params)
    Repo.insert(changeset)
  end
end
