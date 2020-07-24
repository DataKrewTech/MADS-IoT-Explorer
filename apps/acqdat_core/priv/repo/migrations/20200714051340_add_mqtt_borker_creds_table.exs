defmodule AcqdatCore.Repo.Migrations.AddMqttBorkerCredsTable do
  use Ecto.Migration

  def change do
    create table(:acqdat_broker_credentials) do
      add(:entity_uuid, :string, null: false)
      add(:access_token, :string, null: false)
      add(:entity_type, :string, null: false)
      add(:subscriptions, {:array, :map})

      timestamps(type: :timestamptz)
    end

    create unique_index(:acqdat_broker_credentials, [:entity_uuid, :entity_type],
      name: :broker_uuid_unique_constraint)
  end
end
