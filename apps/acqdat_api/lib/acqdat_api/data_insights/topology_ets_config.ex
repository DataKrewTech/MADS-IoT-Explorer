defmodule AcqdatApiWeb.DataInsights.TopologyEtsConfig do
  @moduledoc """
  Provide data-store for Project Topology.
  """

  @ets_table :proj_topology

  @doc """
  Initialize the data-store table.
  """
  def start do
    if :ets.info(@ets_table) == :undefined do
      :ets.new(@ets_table, [:public, :named_table])
    end

    :ok
  end

  @doc """
  Clear all the data in data-store table.
  """
  def clear do
    if :ets.info(@ets_table) != :undefined do
      :ets.delete_all_objects(@ets_table)
    end
  end

  @doc """
  Get the configuration value.
  """
  def get(key) do
    start()
    :ets.lookup(@ets_table, key) || []
  end

  @doc """
  Set the configuration value.
  """
  def set(key, value) do
    start()
    :ets.insert(@ets_table, {key, value})
    value
  end
end
