# Script for populating the database. You can run it as:
#
#     mix run priv/repo/data_feeder.exs
#
alias AcqdatCore.Seed.DataFeeder.Project, as: ProjectDataFeeder
alias AcqdatCore.Seed.DataFeeder.Sensor
alias AcqdatCore.Seed.DataFeeder.Widget
alias AcqdatCore.Seed.DataFeeder.OrgAndUser

# The order here is important, don't modify it.

Widget.seed_data!()
ProjectDataFeeder.seed_data!()
ProjectDataFeeder.seed_gateway()
Sensor.seed_data!()
OrgAndUser.seed_data!()
