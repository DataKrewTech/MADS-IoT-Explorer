defmodule AcqdatCore.Repo.Migrations.DropUserDetails do
  use Ecto.Migration

  def up do
    alter table("users") do
      remove(:first_name)
      remove(:last_name)
      remove(:email)
      remove(:password_hash)
      remove(:phone_number)
    end
  end

  def down do
    alter table("users") do
      add(:first_name, :string)
      add(:last_name, :string)
      add(:email, :citext)
      add(:password_hash, :string)
      add(:phone_number, :string)
    end
  end
end
