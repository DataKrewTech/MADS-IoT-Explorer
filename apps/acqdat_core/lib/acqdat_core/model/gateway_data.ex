defmodule AcqdatCore.Model.GatewayData do
  @moduledoc """
  The Module exposes helper functions to interact with gateway_data
  data.
  """
  import Ecto.Query
  alias AcqdatCore.Schema.GatewayData
  alias AcqdatCore.Repo

  # TODO:: Need to add differenet actions for all the read queries from timescale, as per the future requirements

  def create(params) do
    changeset = GatewayData.changeset(%GatewayData{}, params)
    Repo.insert(changeset)
  end
end
