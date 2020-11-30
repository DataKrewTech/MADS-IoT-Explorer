# Script for populating the database. You can run it as:
#
#     mix run priv/repo/seeds.exs
#
# Inside the script, you can read and write to any of your
# repositories directly:
#
#     Acqdat.Repo.insert!(%Acqdat.SomeSchema{})
#
# We recommend using the bang functions (`insert!`, `update!`
# and so on) as they will fail if something goes wrong.

alias AcqdatCore.Seed.RoleManagement.{User, Role, App}
alias AcqdatCore.Seed.EntityManagement.{Sensor, Organisation, Asset, Project, SensorsData}
alias AcqdatCore.Seed.Widget
alias AcqdatCore.Seed.DataFeeder.Project, as: ProjectDataFeeder
alias AcqdatCore.Seed.DataFeeder.Sensor

# The order here is important, don't modify it.

Organisation.seed_organisation!()
Role.seed()
User.seed_user!()
Project.seed!()
Asset.seed_asset!()
Sensor.seed_sensors()
Widget.seed()
App.seed()
SensorsData.seed!()
ProjectDataFeeder.seed_data!()
ProjectDataFeeder.seed_gateway()
Sensor.seed_data!()
