defmodule AcqdatCore.Repo.Migrations.CreateInvitationEmailUnique do
  use Ecto.Migration

  def change do
    drop(index(:acqdat_invitations, [:email]))
    create(unique_index(:acqdat_invitations, [:email]))
  end
end
