defmodule AcqdatCore.DataCruncher.Schema.Workflow do
  @moduledoc """
  Models a workflow.

  A workflow schema consists of a graph and data with which nodes/vertices in the
  graph are intitialized.
  Workflow is directly associated to task, each task can have multiple workflows.
  """

  use AcqdatCore.Schema
  alias AcqdatCore.Schema.EntityManagement.Organisation
  alias AcqdatCore.DataCruncher.Schema.Tasks

  @type t :: %__MODULE__{}

  schema("acqdat_workflows") do
    field(:uuid, :string, null: false)
    field(:graph, :map)
    field(:input_data, {:array, :map})

    # associations
    belongs_to(:org, Organisation, on_replace: :delete)
    belongs_to(:task, Tasks, on_replace: :delete)

    timestamps(type: :utc_datetime)
  end

  @required ~w(uuid graphs data)a

  def changeset(%__MODULE__{} = workflow, params) do
    workflow
    |> cast(params, @required)
    |> validate_required(@required)
    |> assoc_constraint(:org)
    |> assoc_constraint(:task)
    |> add_uuid()
  end
end
