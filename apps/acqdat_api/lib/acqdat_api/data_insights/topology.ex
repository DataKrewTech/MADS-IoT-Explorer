defmodule AcqdatApiWeb.DataInsights.Topology do
  alias AcqdatCore.Model.EntityManagement.Project, as: ProjectModel
  alias AcqdatCore.Model.EntityManagement.SensorType, as: SensorTypeModel
  alias AcqdatCore.Model.EntityManagement.AssetType, as: AssetTypeModel
  alias AcqdatApiWeb.DataInsights.TopologyEtsConfig
  alias NaryTree
  import AcqdatApiWeb.Helpers

  @table :proj_topology

  def entities(data) do
    sensor_types = SensorTypeModel.get_all(data)
    asset_types = AssetTypeModel.get_all(data)
    %{topology: %{sensor_types: sensor_types || [], asset_types: asset_types || []}}
  end

  def gen_topology(org_id, project) do
    proj_key = project |> ets_proj_key()
    data = proj_key |> TopologyEtsConfig.get()

    # Note: if value is not there for the respective proj_key in ets table, then do following things:
    # 1. fetch project topology
    # 2. set fetched project topology to ets table, with key being project_id + project_version
    res =
      if data != [] do
        [{_, tree}] = data
        tree
      else
        topology_map = ProjectModel.gen_topology(org_id, project.id)
        TopologyEtsConfig.set(proj_key, topology_map)
      end
  end

  def gen_sub_topology(org_id, project_id, _params) do
    topology_map = gen_topology(org_id, project_id)
    parent_tree = NaryTree.from_map(topology_map)
  end

  defp ets_proj_key(project) do
    "#{project.id}_#{project.version}"
  end
end
