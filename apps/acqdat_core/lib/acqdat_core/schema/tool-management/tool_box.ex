defmodule AcqdatCore.Schema.ToolManagement.ToolBox do
  @moduledoc """
  Models a ToolBox.

  A tool box can have multiple tools inside it.
  The tool box belongs to a factory.
  """

  use AcqdatCore.Schema
  alias AcqdatCore.Schema.ToolManagement.Tool
  @tb_prefix "TB"

  @typedoc """
  `name`: Name assigned to toolbox.
  `description`: Some meta data to be stored for the toolbox.
  `uuid`: unique id by which the toolbox can be identified.
  """
  @type t :: %__MODULE__{}

  schema("acqdat_tm_tool_boxes") do
    field(:name, :string)
    field(:description, :string)
    field(:uuid, :string)

    has_many(:tools, Tool)

    timestamps(type: :utc_datetime)
  end

  @required_params ~w(name uuid)a
  @optional_params ~w(description)a

  @permitted @required_params ++ @optional_params

  @spec create_changeset(__MODULE__.t(), map) :: Ecto.Changeset.t()
  def create_changeset(%__MODULE__{} = tool_box, params) do
    tool_box
    |> cast(params, @permitted)
    |> add_uuid()
    |> common_changeset()
  end

  @spec update_changeset(__MODULE__.t(), map) :: Ecto.Changeset.t()
  def update_changeset(%__MODULE__{} = tool_box, params) do
    tool_box
    |> cast(params, @permitted)
    |> common_changeset()
  end

  defp common_changeset(changeset) do
    changeset
    |> validate_required(@required_params)
    |> unique_constraint(:name)
  end
end
