defmodule AcqdatApiWeb.DataCruncher.TasksView do
  use AcqdatApiWeb, :view
  alias AcqdatApiWeb.DataCruncher.WorkflowView
  alias AcqdatApiWeb.DataCruncher.TasksView

  def render("index.json", task) do
    %{
      tasks: render_many(task.entries, TasksView, "task_details.json"),
      page_number: task.page_number,
      page_size: task.page_size,
      total_entries: task.total_entries,
      total_pages: task.total_pages
    }
  end

  def render("task_details.json", %{tasks: task}) do
    %{
      id: task.id,
      name: task.name,
      uuid: task.uuid,
      type: task.type,
      slug: task.slug,
      created_at: task.inserted_at,
      user: render_one(task.user, TasksView, "user_details.json")
    }
  end

  def render("task.json", %{task: task}) do
    %{
      id: task.id,
      name: task.name,
      uuid: task.uuid,
      type: task.type,
      slug: task.slug,
      workflows: render_many(task.workflows, WorkflowView, "workflow.json")
    }
  end

  def render("user_details.json", %{tasks: user_details}) do
    %{
      id: user_details.id,
      email: user_details.email,
      first_name: user_details.first_name,
      last_name: user_details.last_name,
      image: user_details.avatar,
      role_id: user_details.role_id
    }
  end
end
