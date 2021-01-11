alias AcqdatCore.Model.EntityManagement.Sensor

alias AcqdatCore.Seed.DataInsights.Topology

{:ok, occupancy_sensor} = Sensor.get(1)
{:ok, energy_sensor} = Sensor.get(2)
{:ok, heat_sensor} = Sensor.get(3)
