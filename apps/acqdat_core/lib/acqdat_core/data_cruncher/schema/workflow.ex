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
    belongs_to(:task, Tasks, on_replace: :delete)

    timestamps(type: :utc_datetime)
  end

  @required ~w(graph input_data uuid)a

  def changeset(%__MODULE__{} = workflow, params) do
    workflow
    |> cast(params, @required)
    |> add_uuid()
    |> validate_required(@required)
    |> assoc_constraint(:task)
  end
end
