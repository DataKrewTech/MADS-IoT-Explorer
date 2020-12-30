defmodule AcqdatCore.Factory.ElasticSearch.SensorType do
  alias AcqdatApi.ElasticSearch
  import AcqdatCore.Support.Factory
  import Tirexs.HTTP

  def seed_sensor_type(sensor_type) do
    ElasticSearch.insert_sensor_type("sensor_types", sensor_type)
  end

  def delete_index() do
    delete("/sensor_types")
  end

  def seed_multiple_sensor_type(project, count) do
    [sensor_type1, sensor_type2, sensor_type3] =
      insert_list(count, :sensor_type, project: project, org: project.org)

    ElasticSearch.insert_sensor_type("sensor_types", sensor_type1)
    ElasticSearch.insert_sensor_type("sensor_types", sensor_type2)
    ElasticSearch.insert_sensor_type("sensor_types", sensor_type3)
    [sensor_type1, sensor_type2, sensor_type3]
  end
end
