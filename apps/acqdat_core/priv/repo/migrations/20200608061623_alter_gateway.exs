defmodule AcqdatCore.Repo.Migrations.AlterGateway do
  use Ecto.Migration

  def change do
    alter table("acqdat_gateway") do
      add(:image_url, :string)
      add(:current_location, :map)
      add(:channel, :string, null: false)
      add(:static_data, {:array, :map})
      add(:streaming_data, {:array, :map})
      add(:mapped_parameters, :map)
      add(:timestamp_mapping, :string)
    end

    create unique_index("acqdat_gateway", [:name, :org_id, :project_id])
  end
end
