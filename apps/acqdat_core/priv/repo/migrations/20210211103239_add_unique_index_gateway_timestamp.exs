defmodule AcqdatCore.Repo.Migrations.AddUniqueIndexGatewayTimestamp do
  use Ecto.Migration

  def change do
    create unique_index(:acqdat_gateway_data_dump,
      [:inserted_timestamp, :gateway_uuid])
  end
end
