defmodule AcqdatCore.Repo.Migrations.AddTypeToInvitationsTable do
  use Ecto.Migration

  def change do
    alter table("acqdat_invitations") do
      add(:type, :string, default: "new_user")
      add(:metadata, :map)
    end
    drop(index(:acqdat_invitations, [:email]))
    create unique_index(:acqdat_invitations, [:email, :org_id], name: :unique_email_per_org)
  end
end
