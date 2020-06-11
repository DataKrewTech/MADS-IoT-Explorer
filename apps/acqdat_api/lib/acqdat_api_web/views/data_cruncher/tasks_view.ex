defmodule AcqdatApiWeb.DataCruncher.TasksView do
  use AcqdatApiWeb, :view
  alias AcqdatApiWeb.DataCruncher.WorkflowView

  def render("task.json", %{task: task}) do
    %{
      id: task.id,
      name: task.name,
      uuid: task.uuid,
      type: task.type,
      slug: task.slug,
      workflows: render_many(task.workflows, WorkflowView , "workflow.json")
    }
  end
end