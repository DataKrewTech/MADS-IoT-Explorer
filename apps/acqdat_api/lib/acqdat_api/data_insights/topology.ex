defmodule AcqdatApiWeb.DataInsights.Topology do
  alias AcqdatCore.Model.EntityManagement.Project, as: ProjectModel
  alias AcqdatCore.Model.EntityManagement.SensorType, as: SensorTypeModel
  alias AcqdatCore.Model.EntityManagement.AssetType, as: AssetTypeModel
  import AcqdatApiWeb.Helpers

  defdelegate gen_topology(org_id, project_id), to: ProjectModel

  def entities(data) do
    sensor_types = SensorTypeModel.get_all(data)
    asset_types = AssetTypeModel.get_all(data)
    %{topology: (sensor_types || []) ++ (asset_types || [])}
  end
end
