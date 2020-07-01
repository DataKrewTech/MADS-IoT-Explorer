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
    create("organisation", org)
  end

  def create(type, params) do
    put("/organisation",%{mappings: %{properties: %{join_field: %{type: "join", relations: %{organisation: "user"}}}}})
    post("#{type}/_doc/#{params.id}",
      id: params.id,
      name: params.name,
      uuid: params.uuid,
      "join_field": "organisation"
      )
  end

end
