# Script for populating the database. You can run it as:
#
#     mix run priv/repo/update_user.exs
#

alias AcqdatCore.Seed.RoleManagement.UpdateUser

UpdateUser.seed_data!()
