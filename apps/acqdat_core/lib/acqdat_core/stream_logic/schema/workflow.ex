defmodule AcqdatCore.StreamLogic.Schema.Workflow do
  @moduledoc """
  Models a workflow in the stream logic.

  A workflow is combination of stream logic nodes which process the incoming
  message block depending on the logic created by the connection.
  """

  use AcqdatCore.Schema
  alias AcqdatCore.Schema.EntityManagement.{Project, Organisation}
  alias AcqdatCore.StreamLogic.Schema.Workflowgraph

  @type t :: %__MODULE__{}

  schema("acqdat_sl_workflow") do
    field(:name, :string, null: false)
    field(:description, :string)
    field(:uuid, :string, null: false)
    field(:enabled, :boolean, default: true)
    field(:metadata, :map, default: %{})

    #embeds
    embeds_one(:digraph, Workflowgraph, on_replace: :update)

    #associations
    belongs_to(:project, Project)
    belongs_to(:org, Organisation)

    timestamps(type: :utc_datetime)
  end

  @required ~w(name project_id org_id)a
  @optional ~w(enabled metadata description)a

  @permitted @required ++ @optional

  def changeset(%__MODULE__{} = workflow, params) do
    workflow
    |> cast(params, @permitted)
    |> add_uuid()
    |> validate_required(@required)
    |> common()
  end

  def update_changeset(%__MODULE__{}=workflow, params) do
    workflow
    |> cast(params, @permitted)
    |> validate_required(@required)
    |> common()
  end

  defp common(changeset) do
    changeset
    |> cast_embed(:digraph)
    |> assoc_constraint(:project)
    |> assoc_constraint(:org)
    |> unique_constraint(:name,
      name: :unique_flow_name_per_project,
      message: "workflow with this name exists"
    )
  end

end

defmodule AcqdatCore.StreamLogic.Schema.Workflowgraph do
  use AcqdatCore.Schema
  alias AcqdatCore.StreamLogic.Schema.Edge
  alias AcqdatCore.StreamLogic.Schema.Vertex

  embedded_schema() do
    embeds_many(:edge_list, Edge)
    embeds_many(:vertices, Vertex)
  end

  def changeset(%__MODULE__{} = data, params) do
    data
    |> cast(params, [])
    |> cast_embed(:edge_list)
    |> cast_embed(:vertices)
  end
end

defmodule AcqdatCore.StreamLogic.Schema.Edge do
  use AcqdatCore.Schema

  embedded_schema() do
    field(:source_id, :string)
    field(:target_id, :string)
    field(:label, :map)
  end

  @permitted ~w(source_id target_id label)a

  def changeset(%__MODULE__{} = data, params) do
    data
    |> cast(params, @permitted)
    |> validate_required(@permitted)
  end
end


defmodule AcqdatCore.StreamLogic.Schema.Vertex do
  use AcqdatCore.Schema

  embedded_schema() do
    field(:uuid, :string)
    field(:label, :string)
    field(:description, :string)
    field(:module, StreamLogicFunctionEnum)
    field(:configuration, :map)
  end

  @required ~w(label module uuid)a
  @optional ~w(description configuration)a
  @permitted @required ++ @optional

  def changeset(%__MODULE__{} = data, params) do
    data
    |> cast(params, @permitted)
    |> validate_required(@required)
  end
end
