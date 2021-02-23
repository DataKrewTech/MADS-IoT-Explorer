defmodule AcqdatCore.Repo.Migrations.AddGatewayError do
  use Ecto.Migration

  def change do
    create table("acqdat_gateway_error") do
      add(:data, :map, null: false)
      add(:error, :map, null: false)
      add(:gateway_uuid, references("acqdat_gateway", on_delete: :restrict,
        column: :uuid, type: :varchar),
        null: false
      )

      timestamps(type: :timestamptz)
    end
  end
end
