defmodule AcqdatCore.Repo.Migrations.CreateGatewayTable do
  use Ecto.Migration

  def change do
    create table("acqdat_gateway") do
      add(:uuid, :string, null: false)
      add(:slug, :string, null: false)
      add(:org_id, references("acqdat_organisation", on_delete: :delete_all), null: false)
      add(:parent_type, :string)
      add(:parent_id, :integer)
      add(:parameters, :map)
      add(:name, :string)      
      add(:description, :text)
      add(:access_token, :string, null: false)
      add(:serializer, :map)

      timestamps(type: :timestamptz)
    end

    create unique_index("acqdat_gateway", [:slug])
    create unique_index("acqdat_gateway", [:uuid])
    create unique_index("acqdat_gateway", [:access_token])
  end
end
