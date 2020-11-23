defmodule AcqdatCore.Repo.Migrations.AcqdatRecoveryDetails do
  use Ecto.Migration

  def change do
    create table("acqdat_recovery_details") do
      add(:token, :text, null: false)
      add(:user_id, references(:users, on_delete: :delete_all))
      timestamps(type: :timestamptz)
    end

    create unique_index("acqdat_recovery_details", [:token], name: :unique_token_per_user)
  end
end
