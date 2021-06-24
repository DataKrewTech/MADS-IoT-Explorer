defmodule AcqdatApiWeb.StreamLogic.WorkflowView do
  use AcqdatApiWeb, :view
  alias AcqdatApiWeb.StreamLogic.WorkflowGraphView

  def render("index.json", %{workflows: workflows}) do
    %{
      workflows: render_many(workflows.entries, __MODULE__, "show.json"),
      page_number: workflows.page_number,
      page_size: workflows.page_size,
      total_entries: workflows.total_entries,
      total_pages: workflows.total_pages
    }
  end

  def render("show.json", %{workflow: workflow}) do
    %{
      id: workflow.id,
      name: workflow.name,
      description: workflow.description,
      uuid: workflow.uuid,
      digraph: render(WorkflowGraphView, "digraph.json", %{digraph: workflow.digraph}),
      enabled: workflow.enabled,
      metadata: workflow.metadata
    }
  end
end


defmodule AcqdatApiWeb.StreamLogic.WorkflowGraphView do
  use AcqdatApiWeb, :view
  alias AcqdatApiWeb.StreamLogic.EdgeView
  alias  AcqdatApiWeb.StreamLogic.VertexView

  def render("digraph.json", %{digraph: digraph}) do
    %{
      edge_list: render_many(digraph.edge_list, EdgeView, "edge.json", as: :edge),
      vertices: render_many(digraph.vertices, VertexView, "vertex.json", as: :vertex)
    }
  end
end


defmodule AcqdatApiWeb.StreamLogic.EdgeView do
  use AcqdatApiWeb, :view

  def render("edge.json", %{edge: edge}) do
    %{
      source_id: edge.source_id,
      target_id: edge.target_id,
      label: edge.label
    }
  end
end


defmodule AcqdatApiWeb.StreamLogic.VertexView do
  use AcqdatApiWeb, :view
  def render("vertex.json", %{vertex: vertex}) do
    %{
     uuid: vertex.uuid,
     label: vertex.label,
     description: vertex.description,
     module: vertex.module,
     configuration: vertex.configuration
    }
  end
end
