defmodule AcqdatCore.DataCruncher.Schema.Tasks do
  @moduledoc """
  Models a Task for DataCruncher App.

  Tasks are used for performing complex data processing tasks on either raw
  or already processed data.

  A `task` refers to a data processing pipeline that is created by the user.
  A user can create different tasks to perform different types of operations on
  raw or processed data.

  A task consists of multiple workflows/graphs. Data Cruncher app makes use of Flow Based
  Programming to create data processing pipelines. A workflow/graph is represented
  using a directed acyclic graph of `components` connected by edges.
  See `Virta.Component`.
  """
  use AcqdatCore.Schema
  alias AcqdatCore.Schema.EntityManagement.Organisation
  alias AcqdatCore.Schema.RoleManagement.User
  alias AcqdatCore.DataCruncher.Schema.Workflow

  @task_types ~w(one_time periodic triggered)a

  @typedoc """
  `workflows`: Workflows which are present in the task. See `Workflow`.
  `task_type`: Defines what kind of a task it is, it can be one of `one_time`,
              `periodic`, or `triggered`.
  """
  @type t :: %__MODULE__{}
  schema("acqdat_tasks") do
    field(:type, :string)
    field(:uuid, :string, null: false)
    field(:slug, :string, null: false)

    belongs_to(:org, Organisation, on_replace: :delete)
    belongs_to(:user, User, on_replace: :raise)

    embeds_many(:workflows, Workflow, on_replace: :delete)

    timestamps(type: :utc_datetime)
  end

  @required ~w(uuid slug org_id user_id)a
  @embedded_workflow_required ~w(graphs data)a

  @doc """
  Returns a changeset for performing `create` and `update` operations.

  **Note**
  Workflows set inside a task are set as embedded params, please make sure
  to pass in the entire list of workflows during `update` operation else
  it would be removed from the record.
  See `Ecto.Changeset.cast_embed(changeset, name, opts \\ [])` and
  `Ecto.Changeset.cast_assoc(changeset, name, opts \\ [])`
  """
  def changeset(%__MODULE__{} = task, params) do
    task
    |> cast(params, @required)
    |> assoc_constraint(:org)
    |> assoc_constraint(:user)
    |> validate_inclusion(:type, @task_types)
    |> add_slug()
    |> add_uuid()
    |> cast_embed(:workflows, with: &Workflow.changeset/2)
  end
end

defmodule AcqdatCore.DataCruncher.Schema.Workflow do
  @moduledoc """
  Models a workflow.

  A workflow schema consists of a graph and data with which nodes/vertices in the
  graph are intitialized.
  """


  use AcqdatCore.Schema

  @type t :: %__MODULE__{}

  embedded_schema do
    field(:graph, :map)
    field(:data, {:array, :map})
    field(:output, {:array, :map})
  end

  def changeset(%__MODULE__{} = workflow, params) do
    workflow
    |> cast(params, [:graph, :data, :output])
  end
end
