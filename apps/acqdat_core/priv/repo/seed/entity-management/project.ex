defmodule AcqdatCore.Seed.EntityManagement.Project do

  alias AcqdatCore.Schema.EntityManagement.{Organisation, Project}
  alias AcqdatCore.Schema.RoleManagement.User
  alias AcqdatCore.Repo

  def seed!() do
    [org] = Repo.all(Organisation)
    [creator | _] = Repo.all(User)
    params = %{
      name: "Demo Project",
      org_id: org.id,
      creator_id: creator.id
    }
    proj = Project.changeset(%Project{}, params)
    Repo.insert!(proj, on_conflict: :nothing)
  end
end
