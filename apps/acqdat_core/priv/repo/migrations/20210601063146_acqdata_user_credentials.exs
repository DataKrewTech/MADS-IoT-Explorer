defmodule AcqdatCore.Repo.Migrations.AcqdataUserCredentials do
  use Ecto.Migration

  def change do
    create table("acqdat_user_credentials") do
      add(:first_name, :string, null: false)
      add(:last_name, :string)
      add(:email, :citext, null: false)
      add(:password_hash, :string, null: false)
      add(:phone_number, :string)

      timestamps(type: :timestamptz)
    end

    create unique_index("acqdat_user_credentials", [:email])
  end
end
