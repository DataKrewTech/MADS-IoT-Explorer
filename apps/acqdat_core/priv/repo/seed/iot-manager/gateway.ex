defmodule AcqdatCore.Seed.IoTManager.Gateway do

  alias AcqdatCore.Schema.IotManager.Gateway
  alias AcqdatCore.Schema.EntityManagement.{Organisation, Asset, Project}
  alias AcqdatCore.Repo

  @gateway_params %{
    name: "Gateway1",
    access_token: "xyz1234asdf",
    parent_type: "Project",
    channel: "http"
  }


  def seed_gateway() do
    [org] = Repo.all(Organisation)
    [project | _] = Repo.all(Project)

    params =
      @gateway_params
      |> Map.put(:org_id, org.id)
      |> Map.put(:project_id, project.id)
      |> Map.put(:parent_id, project.id)

    changeset = Gateway.changeset(%Gateway{}, params)
    Repo.insert!(changeset)
  end

end
