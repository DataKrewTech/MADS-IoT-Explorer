defmodule AcqdatCore.Seed.EntityManagement.Organisation do

  alias AcqdatCore.Schema.EntityManagement.Organisation
  alias AcqdatCore.Repo
  import Tirexs.HTTP

  def seed_organisation!() do
    params = %{
      name: "DataKrew",
      uuid: "4219171e733a11e9a42fe86a64b144a9",
      inserted_at: DateTime.truncate(DateTime.utc_now(), :second),
      updated_at: DateTime.truncate(DateTime.utc_now(), :second)
    }
    organisation = Organisation.changeset(%Organisation{}, params)
    org = Repo.insert!(organisation, on_conflict: :nothing)
  end

  def create(type, params) do
    post("#{type}/_doc/#{params.id}",
      id: params.id,
      email: params.email,
      first_name: params.first_name,
      last_name: params.last_name,
      org_id: params.org_id,
      is_invited: params.is_invited,
      role_id: params.role_id)
  end

end
