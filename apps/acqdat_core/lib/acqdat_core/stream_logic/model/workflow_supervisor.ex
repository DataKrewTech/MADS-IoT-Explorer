defmodule AcqdatCore.StreamLogic.Model.WorkflowSupervisor do
  @moduledoc """
  A dynamic supervsior to monitor logic chains for a project.

  This supervisor is started per project whenever a project is created
  and it monitors all the consumer groups which are created under the project.
  """

  use DynamicSupervisor

  def start_link(init_arg) do
    project_uuid = Keyword.get(init_arg, :project_uuid)
    DynamicSupervisor.start_link(__MODULE__, [], name: project_uuid)
  end

  def init(_init_arg) do
    DynamicSupervisor.init(strategy: :one_for_one)
  end

end
