defmodule AcqdatApi.Alerts.AlertFilterListing do
  @moduledoc """
  All the helper functions related to alert rules listing.
  """
  def list_status() do
    Map.keys(AlertStatusEnum.__enum_map__())
  end

  def list_app() do
    Map.keys(AppEnum.__enum_map__())
  end
end
