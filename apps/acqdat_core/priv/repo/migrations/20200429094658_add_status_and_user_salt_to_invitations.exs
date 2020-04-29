defmodule AcqdatCore.Repo.Migrations.AddStatusAndUserSaltToInvitations do
  use Ecto.Migration

  def up do
    alter table("acqdat_invitations") do
      add(:token_valid, :boolean, default: true)
      add(:salt, :string, null: false)
    end
    
    create(unique_index(:acqdat_invitations, [:salt]))
  end

  def down do
    drop unique_index(:acqdat_invitations, [:salt])

    alter table("acqdat_invitations") do
      remove(:salt)
      remove(:token_valid)
    end
  end
end
