defmodule AcqdatApiWeb.DataCruncher.WorkflowView do
  use AcqdatApiWeb, :view
  alias AcqdatApiWeb.DataCruncher.TempOutputView

  def render("workflow.json", %{workflow: workflow}) do
    %{
      id: workflow.id,
      uuid: workflow.uuid,
      graph: workflow.graph,
      input_data: workflow.input_data,
      temp_output: render_many(workflow.temp_output, TempOutputView, "output.json")
    }
  end
end
