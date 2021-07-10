defmodule AcqdatCore.Seed.RoleManagement.Role do
  alias AcqdatCore.Schema.RoleManagement.Role
  alias AcqdatCore.Model.RoleManagement.Role, as: RModel
  alias AcqdatCore.Repo

  #@roles ~w(admin manager member)s
  @new_roles ~w(superadmin orgadmin member)s


  def seed() do
    Enum.each(@new_roles, fn role ->
      Role.changeset(%Role{}, %{name: role})
      |> Repo.insert!()
    end)
  end

  def modify() do
    RModel.get_all()
    |> Enum.each(fn %{name: name} = role ->
      current_role = case name do
        "admin" ->
          "superadmin"
        "manager" ->
          "orgadmin"
        _ ->
          "member"
      end
      RModel.update(role, %{name: current_role})
    end)
  end
end
