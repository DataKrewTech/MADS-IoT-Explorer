defmodule AcqdatCore.Model.EntityManagement.GatewayData do
  @moduledoc """
  The Module exposes helper functions to interact with gateway_data
  data.
  """
  import Ecto.Query
  alias AcqdatCore.Schema.EntityManagement.GatewayData
  alias AcqdatCore.Repo

  # TODO:: Need to add differenet actions for all the read queries from timescale, as per the future requirements

  def create(params) do
    changeset = GatewayData.changeset(%GatewayData{}, params)
    Repo.insert(changeset)
  end

  def get_all_by_parameters(entity_id, param_name, date_from, date_to) do
    subquery =
      from(
        data in GatewayData,
        where:
          data.gateway_id == ^entity_id and data.inserted_timestamp >= ^date_from and
            data.inserted_timestamp <= ^date_to
      )

    query =
      from(
        data in subquery,
        cross_join: c in fragment("unnest(?)", data.parameters),
        where: fragment("?->>'name'=?", c, ^param_name),
        select: [
          data.inserted_timestamp,
          fragment("?->>'value'", c)
        ]
      )

    Repo.all(query)
  end
end
