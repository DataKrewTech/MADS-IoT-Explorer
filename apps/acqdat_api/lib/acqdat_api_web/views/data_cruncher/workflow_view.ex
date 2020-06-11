defmodule AcqdatApiWeb.DataCruncher.WorkflowView do
  use AcqdatApiWeb, :view

  def render("workflow.json", %{workflow: workflow}) do
    %{
      id: workflow.id,
      graph: workflow.graph,
      input_data: workflow.input_data
    }
  end
end