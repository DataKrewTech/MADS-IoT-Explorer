defmodule AcqdatCore.Repo.Migrations.CreateTableInvitations do
  use Ecto.Migration

  def up do
    create table(:acqdat_invitations) do
      add(:email, :string, null: false)
      add(:token, :string, null: false)
      add(:asset_ids, {:array, :integer})
      add(:app_ids, {:array, :integer})
      add(:inviter_id, references(:users))
      add(:role_id, references(:acqdat_roles), null: false)
      add(:org_id, references(:acqdat_organisation, on_delete: :delete_all, null: false))
      timestamps()
    end
    create(unique_index(:acqdat_invitations, [:token]))
    create(unique_index(:acqdat_invitations, [:email]))
  end

  def down do
    drop(unique_index(:acqdat_invitations, [:email]))
    drop(unique_index(:acqdat_invitations, [:token]))
    drop(table(:acqdat_invitations))
  end
end
