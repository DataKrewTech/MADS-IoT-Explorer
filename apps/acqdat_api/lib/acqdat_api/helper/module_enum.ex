import EctoEnum

alias AcqdatCore.Model.EntityManagement.{Project, SensorType, Sensor, Asset, AssetType}

@doc """
  This is a very important Enum. This will help in creating a generic API for counting the number of records that you need to
  show the number of records for any respective portal. So if you add any new table which is going to hold a record by itself.
  1. Copy and modify the return count function from any one of the file aliased above.
  2. Alias that model here.
  3. Add enum for that table.
"""
defenum(ModuleEnum,
  Project: Project,
  Asset: Asset,
  Sensor: Sensor,
  AssetType: AssetType,
  SensorType: SensorType
)
