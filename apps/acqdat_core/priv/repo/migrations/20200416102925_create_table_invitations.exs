defmodule AcqdatCore.Repo.Migrations.CreateTableInvitations do
  use Ecto.Migration

  def up do
    create table(:acqdat_invitations) do
      add(:email, :string, null: false)
      add(:token, :string, null: false)
      add(:asset_ids, {:array, :integer})
      add(:app_ids, {:array, :integer})
      add(:inviter_id, references(:users))
      timestamps()
    end
  end

  def down do
    drop(table(:acqdat_invitations))
  end
end
