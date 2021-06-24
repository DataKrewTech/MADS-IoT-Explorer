defmodule AcqdatApi.EntityManagement.Project do

  import AcqdatApiWeb.Helpers
  alias AcqdatCore.Model.EntityManagement.Project, as: ProjectModel
  alias AcqdatCore.Repo
  alias AcqdatCore.Model.IotManager.Gateway
  alias AcqdatCore.Model.EntityManagement.{
    Asset,
    AssetType,
    Sensor,
    SensorType
  }
  alias AcqdatApiWeb.EntityManagement.{
    AssetView,
    AssetTypeView,
    SensorView,
    SensorTypeView
  }
  alias AcqdatApiWeb.IotManager.GatewayView


  defdelegate get_all(data, preloads), to: ProjectModel
  defdelegate get_all_archived(data, preloads), to: ProjectModel
  defdelegate delete(project), to: ProjectModel

  def update(project, params) do
    project = project |> Repo.preload(leads: :user_credentials, users: :user_credentials)
    ProjectModel.update(project, params)
  end

  def create(attrs) do
    verify_project(
      attrs
      |> project_create_attrs()
      |> ProjectModel.create()
    )
  end

  def get_all_users(project) do
    project =
      project
      |> Repo.preload(
        creator: :user_credentials,
        leads: :user_credentials,
        users: :user_credentials
      )

    user_list = project.leads ++ project.users ++ [project.creator]
    user_list |> Enum.uniq()
  end


  def entity_list(%{entity: "gateway"}=params) do
    {GatewayView, Gateway.get_all(params, [:org, :project, :sensors])}
  end
  def entity_list(%{entity: "sensor"}=params) do
    {SensorView, Sensor.get_all_by_project_n_org(params)}
  end
def entity_list(%{entity: "sensor_type"} = params) do
    {SensorTypeView, SensorType.get_all(params)}
  end
  def entity_list(%{entity: "asset"} = params) do
    {AssetView, Asset.get_all(params)}
  end
  def entity_list(%{entity: "asset_type"} = params) do
    {AssetTypeView, AssetType.get_all(params, [:org, :project])}
  end
  def entity_list(_), do: {:none, []}

  ############## private functions ##################

  defp project_create_attrs(
         %{
           lead_ids: lead_ids,
           user_ids: user_ids
         } = params
       ) do
    params = params_extraction(params)

    lead_ids = [-1 | lead_ids]
    user_ids = [-1 | user_ids]

    params
    |> Map.replace!(:lead_ids, lead_ids)
    |> Map.replace!(:user_ids, user_ids)
  end

  defp verify_project({:ok, project}) do
    project = project |> Repo.preload(leads: :user_credentials, users: :user_credentials)
    {:ok, project}
  end

  defp verify_project({:error, project}) do
    {:error, %{error: extract_changeset_error(project)}}
  end

  defp params_extraction(params) do
    Map.from_struct(params)
    |> Map.drop([:_id, :__meta__])
  end
end
