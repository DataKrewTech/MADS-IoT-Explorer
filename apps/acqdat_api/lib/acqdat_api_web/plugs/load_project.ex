defmodule AcqdatApiWeb.Plug.LoadProject do
  import Plug.Conn
  alias AcqdatCore.Model.EntityManagement.Project, as: ProjectModel

  @spec init(any) :: any
  def init(default), do: default

  @spec call(Plug.Conn.t(), any) :: Plug.Conn.t()
  def call(%{params: %{"project_id" => project_id}} = conn, _params) do
    check_project(conn, project_id)
  end

  defp check_project(conn, project_id) do
    {project_id, _} = Integer.parse(project_id)

    case ProjectModel.get_by_id(project_id) do
      {:ok, project} ->
        assign(conn, :project, project)

      {:error, _message} ->
        conn
        |> put_status(404)
    end
  end
end
