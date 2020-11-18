defmodule AcqdatCore.Factory.ElasticSearch.Sensor do
  alias AcqdatApi.ElasticSearch
  import AcqdatCore.Support.Factory
  import Tirexs.HTTP

  def seed_sensor(sensor) do
    ElasticSearch.insert_sensor("sensors", sensor)
  end

  def delete_index() do
    delete("/sensors")
  end

  def seed_multiple_sensors(project) do
    [sensor1, sensor2, sensor3] = insert_list(3, :sensor, project: project, org: project.org)
    ElasticSearch.insert_sensor("sensors", sensor1)
    ElasticSearch.insert_sensor("sensors", sensor2)
    ElasticSearch.insert_sensor("sensors", sensor3)
    [sensor1, sensor2, sensor3]
  end
end
