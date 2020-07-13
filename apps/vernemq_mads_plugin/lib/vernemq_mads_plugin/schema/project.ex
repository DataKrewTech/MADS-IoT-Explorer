defmodule VernemqMadsPlugin.ProjectSchema do
  @moduledoc """
  Module to read data for projects.
  """

  use Ecto.Schema

  schema "acqdat_projects" do
    field(:uuid, :string, null: false)
    field(:name, :string)
  end
end
