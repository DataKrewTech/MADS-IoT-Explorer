import EctoEnum

alias AcqdatCore.Model.EntityManagement.{Project, SensorType, Sensor, Asset, AssetType}
alias AcqdatCore.Model.RoleManagement.Invitation

defenum(ModuleEnum,
  Project: Project,
  Asset: Asset,
  Sensor: Sensor,
  AssetType: AssetType,
  SensorType: SensorType,
  ProjectArchived: Project,
  UserInvite: Invitation
)
