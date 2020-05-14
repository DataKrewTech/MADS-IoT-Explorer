defmodule AcqdatCore.Seed.RoleManagement.Role do
  alias AcqdatCore.Schema.RoleManagement.Role
  alias AcqdatCore.Repo
  
  @roles ~w(admin manager member)s

  def seed() do
    Enum.each(@roles, fn role -> 
      Role.changeset(%Role{}, %{name: role})
      |> Repo.insert()
    end)
  end
end