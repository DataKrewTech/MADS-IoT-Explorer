# Script for populating the database. You can run it as:
#
#     mix run priv/repo/role_and_user.exs
#

alias AcqdatCore.Seed.RoleManagement.Role

Role.modify()
