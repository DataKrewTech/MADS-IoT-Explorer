defmodule AcqdatCore.DataCruncher.Schema.Tasks do
  @moduledoc """
  Models a Task for DataCruncher App.

  Tasks are used for performing complex data processing tasks on either raw
  or already processed data.

  A `task` refers to a data processing pipeline that is created by the user.
  A user can create different tasks to perform different types of operations on
  raw or processed data.

  A task consists of multiple graphs. Data Cruncher app makes use of Flow Based
  Programming to create data processing pipelines. A flow or a graph is represented
  using a directed acyclic graph of components connected by edges.
  """
  use AcqdatCore.Schema
  alias AcqdatCore.Schema.EntityManagement.Organisation
  alias AcqdatCore.Schema.RoleManagement.User

  @task_types ~w(one_time periodic triggered)a

  @typedoc """
  `graphs`: The graphs which defines the flow of data and functions in the task.
  `data`: The intitial data which is passed to the graph to inititate execution.
  `task_type`: Defines what kind of a task it is, it can be one of `one_time`,
              `periodic`, or `triggered`.
  """
  @type t :: %__MODULE__{}
  schema("acqdat_tasks") do
    field(:graphs, {:array, :map})
    field(:data, :map)
    field(:type, :string)

    field(:uuid, :string, null: false)
    field(:slug, :string, null: false)

    belongs_to(:org, Organisation, on_replace: :delete)
    belongs_to(:user, User, on_replace: :raise)
  end

  @required ~w(graphs data type org_id user_id)a

  def changeset(%__MODULE__{} = task, params) do
    task
    |> cast(params, @required)
    |> assoc_constraint(:org)
    |> assoc_constraint(:user)
    |> validate_inclusion(:type, @task_types)
    |> add_slug()
    |> add_uuid()
  end
end
