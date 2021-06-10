defmodule AcqdatCore.Repo.Migrations.CreateRequestsTable do
  use Ecto.Migration

  def change do
    create table("acqdat_requests") do
      add(:first_name, :string, null: false)
      add(:last_name, :string)
      add(:email, :citext, null: false)
      add(:phone_number, :string)
      add(:user_metadata, :map)   
      add(:org_name, :string, null: false)
      add(:org_url, :string, null: false)
      add(:status, :string, default: "pending")

      timestamps(type: :timestamptz)
    end

    create unique_index(:acqdat_requests, [:email, :org_url], name: :unique_email_per_org_url)
  end
end
