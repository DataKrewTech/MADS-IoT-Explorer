defmodule AcqdatCore.Repo.Migrations.AddOrganisationReferenceToUsersTable do
  use Ecto.Migration

  def up do
    alter table(:users) do
      #NOTE:: Need to add not_null check here, either from postgresql or need to write separate migration for the same
      #As, currently if we add not_null check here, if will fail for existing users record whose org_id is not present
      add(:org_id, references("acqdat_organisation", on_delete: :delete_all))
    end

    flush()
    
    create(unique_index(:users, [:org_id, :email]))
  end

  def down do
    drop unique_index(:users, [:org_id, :email])
    drop constraint(:users, "users_org_id_fkey")

    alter table(:users) do
      remove(:org_id)
    end
  end
end
