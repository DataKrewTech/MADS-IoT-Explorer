defmodule AcqdatCore.Schema.ToolManagement.Tool do
  @moduledoc """
  Models a tool or asset that needs to be tracked.
  """

  use AcqdatCore.Schema
  alias AcqdatCore.Schema.ToolManagement.{ToolBox, ToolType}

  @tool_prefix "T"
  @tool_status ~w(issued in_inventory)s

  @typedoc """
  `uuid`: a unique id assigned to the tool.
  `name`: name of the tool.
  `tool_type`: the category to which the tool belongs.
  """

  @type t :: %__MODULE__{}

  schema("acqdat_tm_tools") do
    field(:uuid, :string)
    field(:name, :string)
    field(:status, :string, default: "in_inventory")
    field(:description, :string)

    belongs_to(:tool_box, ToolBox)
    belongs_to(:tool_type, ToolType)
    timestamps(type: :utc_datetime)
  end

  @required ~w(name tool_type_id uuid tool_box_id )a
  @optional ~w(description status)a

  @permitted @required ++ @optional

  @spec create_changeset(__MODULE__.t(), map) :: Ecto.Changeset.t()
  def create_changeset(%__MODULE__{} = tool, params) do
    tool
    |> cast(params, @permitted)
    |> add_uuid()
    |> common_changeset()
  end

  @spec update_changeset(__MODULE__.t(), map) :: Ecto.Changeset.t()
  def update_changeset(%__MODULE__{} = tool, params) do
    tool
    |> cast(params, @permitted)
    |> common_changeset()
  end

  def tool_status() do
    @tool_status
  end

  ################################# private functions ###########################

  defp common_changeset(changeset) do
    changeset
    |> validate_required(@required)
    |> validate_inclusion(:status, @tool_status)
    |> assoc_constraint(:tool_box)
    |> assoc_constraint(:tool_type)
    |> unique_constraint(:name,
      name: :acqdat_tm_tools_name_tool_box_id_index,
      message: "Unique tool name per tool box!"
    )
  end
end
