defmodule AcqdatCore.Seed.RoleManagement.Role do
  alias AcqdatCore.Schema.RoleManagement.Role
  alias AcqdatCore.Model.RoleManagement.Role, as: RModel
  alias AcqdatCore.Repo

  @roles ~w(admin manager member)s
  @new_roles ~w(superadmin orgadmin member)s


  def seed() do
    Enum.each(@roles, fn role ->
      Role.changeset(%Role{}, %{name: role})
      |> Repo.insert()
    end)
  end

  def modify() do
    Enum.zip(@roles, @new_roles)
    |> Enum.each(fn {previous, current} ->
      role = RModel.get_role(previous)
      RModel.update(role, %{name: current})
    end)
  end
end
