defmodule AcqdatCore.Seed.EntityManagement.Organisation do

  alias AcqdatCore.Schema.EntityManagement.Organisation
  alias AcqdatCore.Repo

  def seed_organisation!() do
    params = %{
      name: "DataKrew",
      uuid: "4219171e733a11e9a42fe86a64b144a9",
      inserted_at: DateTime.truncate(DateTime.utc_now(), :second),
      updated_at: DateTime.truncate(DateTime.utc_now(), :second)
    }
    organisation = Organisation.changeset(%Organisation{}, params)
    Repo.insert!(organisation, on_conflict: :nothing)
  end
end
