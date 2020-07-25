defmodule AcqdatCore.DataCruncher.Schema.TempOutput do
  @moduledoc """
  Models a workflow.

  A workflow schema consists of a graph and data with which nodes/vertices in the
  graph are intitialized.
  Workflow is directly associated to task, each task can have multiple workflows.
  """

  use AcqdatCore.Schema
  alias AcqdatCore.DataCruncher.Schema.Workflow

  @type t :: %__MODULE__{}

  schema("acqdat_temp_output") do
    field(:format, :string)
    field(:source_id, :string)
    field(:data, :map)
    field(:async, :boolean, default: false)

    # associations
    belongs_to(:workflow, Workflow, on_replace: :delete)

    timestamps(type: :utc_datetime)
  end

  @required_params ~w(data workflow_id)a
  @optional_params ~w(source_id)a
  @permitted @required_params ++ @optional_params

  def changeset(%__MODULE__{} = temp_output, params) do
    temp_output
    |> cast(params, @permitted)
    |> validate_required(@required_params)
    |> assoc_constraint(:workflow)
  end
end
